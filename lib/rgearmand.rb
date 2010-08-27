require 'rubygems'
require 'eventmachine'
require 'ruby-debug'
require 'logger'
require 'redis'
require 'json'
require 'andand'
require 'ruby-prof'
require 'algorithms'

class Containers::Heap
  def stored
    @stored
  end
end

class Containers::PriorityQueue
  def to_a
    @heap.stored.collect{ |element|  {:key => element[0], :value => element[1][0].value}  }
  end
end

$: << File.dirname(__FILE__)
Debugger.start

COMMANDS = {
  1  => :can_do,               # W->J: FUNC
  2  => :cant_do,              # W->J: FUNC
  3  => :reset_abilities,      # W->J: --
  4  => :pre_sleep,            # W->J: --
  #5 =>  (unused),             # -      -
  6  => :noop,                 # J->W: --
  7  => :submit_job,           # C->J: FUNC[0]UNIQ[0]ARGS
  8  => :job_created,          # J->C: HANDLE
  9  => :grab_job,             # W->J: --
  10 => :no_job,               # J->W: --
  11 => :job_assign,           # J->W: HANDLE[0]FUNC[0]ARG
  12 => :work_status,          # W->J/C: HANDLE[0]NUMERATOR[0]DENOMINATOR
  13 => :work_complete,        # W->J/C: HANDLE[0]RES
  14 => :work_fail,            # W->J/C: HANDLE
  15 => :get_status,           # C->J: HANDLE
  16 => :echo_req,             # ?->J: TEXT
  17 => :echo_res,             # J->?: TEXT
  18 => :submit_job_bg,        # C->J: FUNC[0]UNIQ[0]ARGS
  19 => :error,                # J->?: ERRCODE[0]ERR_TEXT
  20 => :status_res,           # C->J: HANDLE[0]KNOWN[0]RUNNING[0]NUM[0]DENOM
  21 => :submit_job_high,      # C->J: FUNC[0]UNIQ[0]ARGS
  22 => :set_client_id,        # W->J: [RANDOM_STRING_NO_WHITESPACE]
  23 => :can_do_timeout,       # W->J: FUNC[0]TIMEOUT
  24 => :all_yours,            # REQ    Worker
  25 => :work_exception,       # W->J: HANDLE[0]ARG
  26 => :option_req,           # C->J: TEXT
  27 => :option_res,           # J->C: TEXT
  28 => :work_data,            # REQ    Worker
  29 => :work_warning,         # W->J/C: HANDLE[0]MSG
  30 => :grab_job_uniq,        # REQ    Worker
  31 => :job_assign_uniq,      # RES    Worker
  32 => :submit_job_high_bg,   # C->J: FUNC[0]UNIQ[0]ARGS
  33 => :submit_job_low,       # C->J: FUNC[0]UNIQ[0]ARGS
  34 => :submit_job_low_bg,    # C->J: FUNC[0]UNIQ[0]ARGS
  35 => :submit_job_sched,     # REQ    Client
  36 => :submit_job_epoch      # C->J: FUNC[0]UNIQ[0]EPOCH[0]ARGS
}
COMMAND_INV = COMMANDS.invert

PRIORITIES = {
  1 => :high, 
  2 => :normal, 
  3 => :low
}

PQUEUE = Redis.new(:host => "127.0.0.1", :port => 6379)
QUEUES = {}
WORKERS = {}
STATE = {}
JOBS = {}
CLIENTS = {}
NEIGHBORS = {}
HOSTNAME = ARGV[0]

def logger
  @logger ||= if ENV['LOG_TO_STDOUT']
    Logger.new(STDOUT)
  else
    Logger.new("rgearmand.log", File::WRONLY | File::APPEND)
  end
end


# Signals
Signal.trap('INT') { EM.stop }
Signal.trap('TERM'){ EM.stop }

# TODO: Need a round-robin queue for workers.
module Rgearmand
  
  def initialize
    logger.info "Connection from someone..."
    @capabilities = []
    @currentjob = nil

    super
  end
  
  # Overrides for connections
  
  def post_init
    logger.debug "-- someone connected to regearmand!"
  end
  
  def unbind
    logger.debug "-- someone disconnected from regearmand!"
  end

  def receive_data(data)
    offset = 0
    logger.debug "receive <<< #{data.inspect}"
    logger.debug "length <<< #{data.length}"
    
    while(offset < data.length)
      #packet = Protocol.parse(data)
      header = data[offset+0..offset+11]
      type = header[1..3].to_s
      cmd =  COMMANDS[header[4..7].unpack('N').first]
      datalen = header[8..11].unpack('N').first
      args = data[offset+12..offset+12+datalen].split("\0")
    
      offset = offset + datalen + 12
      
      logger.debug "Type: #{type}"
      logger.debug "Cmd: #{cmd}"
      logger.debug "Datalen: #{datalen}"
      logger.debug "Data: #{args}"
    
      self.send(cmd, *args)
    end
  end
  
  # Our code
  def get_job_handle
    STATE[:job_handle_id] ||= 0
    STATE[:job_handle_id] += 1
    STATE[:job_handle_id]
    "H:foo.narf:#{STATE[:job_handle_id]}"
  end
  
  def enqueue(opts = {})
    func_name = opts[:func_name] || opts["func_name"]
    priority = opts[:priority] || opts["priority"] || :normal
    uniq = opts[:uniq] || opts["uniq"] 
    job_handle = get_job_handle
    data = opts[:data] || opts["data"] 
    timestamp = opts[:timestamp] || opts["timestamp"] || 0
    
    unless QUEUES.has_key?(func_name) 
      QUEUES[func_name] = { 
        :normal => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 }, 
        :high => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 }, 
        :low => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 } 
      }
    end
    
    logger.debug "Timestamp: #{timestamp} -> #{timestamp.to_i}"
    QUEUES[func_name][priority].push({:uniq => uniq, :job_handle => "#{job_handle}", :data => data, :timestamp => timestamp.to_i}, timestamp.to_i)
    
    if opts[:persist]
      key = "#{HOSTNAME}-#{uniq}"
      PQUEUE.set key, JSON.dump({:func_name => func_name, :data => data, :uniq => uniq, :timestamp => timestamp})
      PQUEUE.sadd HOSTNAME, key
    end
    
    job_handle
  end
  
  def dequeue(job_handle)
    uniq = JOBS[job_handle][:uniq]
    JOBS.delete(job_handle)
    
    key = "#{HOSTNAME}-#{uniq}"
    logger.debug "Checking for #{key} in persistent queue"
    if PQUEUE.sismember(HOSTNAME, key)
      if !PQUEUE.exists key 
        logger.debug "Removing job from persistent queue"
        PQUEUE.del key
      end
      PQUEUE.srem HOSTNAME, key
    end
  end

  def generate(name, *args)
    logger.debug "G: #{args}"
    args = args.flatten
    num = COMMAND_INV[name]
    arg = args.join("\0")

    data = [
      "\0",
      "RES",
      [num, arg.size].pack('NN'),
      arg
    ].join
  end
  
  def respond(type, *args)
    packet = generate(type, *args)
    logger.debug "response >>> #{packet.inspect}"
    send_data(packet)
  end
  
  # Client commands
  def submit_job_bg(func_name, uniq, data)
    job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :persist => true)
    respond :job_created, job_handle
  end
  
  def submit_job(func_name, uniq, data)
    job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :persist => true)
   
    JOBS[job_handle] = {:client => self , :uniq => uniq}
    respond :job_created, job_handle
        
    WORKERS.has_key?(func_name) && WORKERS[func_name].each do |w|
      logger.debug "Sending NOOP to #{w}"
      packet = generate :noop
      w.send_data(packet)
    end
  end
  
  def submit_job_epoch(func_name, uniq, epoch, data)
    logger.debug "Epoch job submission"
    job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :timestamp => epoch, :persist => true)
    respond :job_created, job_handle
  end

  def get_status(job_handle)
    unless JOBS[job_handle][:numerator].nil?
      # We have status, so send it off
      numerator = JOBS[job_handle][:numerator]
      denominator = JOBS[job_handle][:denominator]
      packet = generate :status_res, job_handle, 1, 0, numerator, denominator 
    else
      # We don't have a status for this packet
      packet = generate :status_res, job_handle, 0, 0, 0, 0
    end
  end
  
  def grab_job(unique = false)
    @capabilities.each do |capability|
      [:high, :normal, :low].each do |priority|
        next unless QUEUES.has_key?(capability)
        jobqueue = QUEUES[capability][priority]
        #logger.debug jobqueue.inspect
        if (jobqueue.size > 0) 
          job = jobqueue.next
          
          if job[:timestamp] == 0 || job[:timestamp] <= Time.now().to_i
            jobqueue.pop
            logger.debug job.inspect
            logger.debug "Found job: #{job.inspect}"

            if !JOBS.has_key? job[:job_handle]
              logger.debug "Adding to run queue..."
              JOBS[job[:job_handle]] = job
            end

            if unique
              respond :job_assign_uniq, job[:job_handle], capability, job[:uniq], job[:data]
            else 
              respond :job_assign, job[:job_handle], capability, job[:data]
            end
          
            return
          else 
            logger.debug "No jobs ready to run"
          end
        end
      end
    end
    
    logger.debug "No job!"
    respond :no_job
  end
  
  
  # Worker commands
  def pre_sleep
  
  end
  
  def can_do(func_name)
    unless WORKERS.has_key?(func_name) 
      WORKERS[func_name] = []
    end
    
    unless @capabilities.include?(func_name)
      @capabilities << func_name
    end
    
    WORKERS[func_name] << self
    
    logger.debug "Workers"
    logger.debug "-------"
    logger.debug WORKERS.inspect
  end
  
  def cant_do(func_name)
    logger.debug "Unregistering #{func_name}"
    WORKERS[func_name].delete self
    @capabilities.delete func_name
  end
  
  def reset_abilities
    @capabilities.each do |cap|
      cant_do cap
    end
  end
  
  def set_client_id(worker_id = nil)
    if worker_id == nil
      worker_id = rand(36**8).to_s()
    end
    @worker_id = worker_id 
  end
  
  def send_client(packet_type, job_handle, *args)
    packet = generate(packet_type, job_handle, args)
    client = JOBS[job_handle][:client]
    client.andand.send_data(packet)
  end
  
  def work_data(job_handle, data)
    send_client :work_data, job_handle, data
  end
  
  def work_warning(job_handle, data)
    send_client :work_warning, job_handle, data
  end
  
  def work_status(job_handle, numerator, denominator)
    JOBS[job_handle][:numerator] = numerator
    JOBS[job_handle][:denominator] = denominator
  end
  
  def work_exception(job_handle, data)
    send_client :work_exception, job_handle, data
    dequeue job_handle
  end
  
  def work_fail(job_handle)
    send_client :work_complete, job_handle
    dequeue job_handle
  end
  
  def work_complete(job_handle, data)
    send_client :work_complete, job_handle, data
    dequeue job_handle
  end
    

end

class GearmanServer
  include Rgearmand

  def initialize 
    # LOAD
    # Read jobs from the persistent queue
    PQUEUE.smembers(HOSTNAME).andand.each do |key|
      logger.debug "Found key: #{key}"
      if PQUEUE.exists key
        jdata = PQUEUE.get("#{key}")
        logger.debug "Found data: #{jdata}"
        if jdata.nil?
          logger.debug "Empty data, removing key... "
          result = PQUEUE.del key
          logger.debug "Deleted #{result} keys"
        else 
          job = JSON.parse(jdata)
          logger.debug "Job: #{job}"
          if job[:uniq].nil?
            job[:uniq] = key.split("-")[1]
          end
          job_handle = self.enqueue job
          logger.debug "Enqueued with handle #{job_handle}"
        end
      else
        logger.debug "Empty job, removing key."
        PQUEUE.srem HOSTNAME, key
      end
      
    end

    require 'manager'

    EventMachine::run {
      EventMachine::start_server "127.0.0.1", 4731, Rgearmand
      Manager.run!({:port => 3000})
    }
    
    
  end
end



logger.debug "#{HOSTNAME} starting up..."
RubyProf.start
gm = GearmanServer.new()
result = RubyProf.stop
# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)

__END__
#   Name                Magic  Type
1   CAN_DO              REQ    Worker
2   CANT_DO             REQ    Worker
3   RESET_ABILITIES     REQ    Worker
4   PRE_SLEEP           REQ    Worker
5   (unused)            -      -
6   NOOP                RES    Worker
7   SUBMIT_JOB          REQ    Client
8   JOB_CREATED         RES    Client
9   GRAB_JOB            REQ    Worker
10  NO_JOB              RES    Worker
11  JOB_ASSIGN          RES    Worker
12  WORK_STATUS         REQ    Worker
12  WORK_STATUS         RES    Client
13  WORK_COMPLETE       REQ    Worker
13  WORK_COMPLETE       RES    Client
14  WORK_FAIL           REQ    Worker
14  WORK_FAIL           RES    Client
15  GET_STATUS          REQ    Client
16  ECHO_REQ            REQ    Client/Worker
17  ECHO_RES            RES    Client/Worker
18  SUBMIT_JOB_BG       REQ    Client
19  ERROR               RES    Client/Worker
20  STATUS_RES          RES    Client
21  SUBMIT_JOB_HIGH     REQ    Client
22  SET_CLIENT_ID       REQ    Worker
23  CAN_DO_TIMEOUT      REQ    Worker
24  ALL_YOURS           REQ    Worker
25  WORK_EXCEPTION      REQ    Worker
25  WORK_EXCEPTION      RES    Client
26  OPTION_REQ          REQ    Client/Worker
27  OPTION_RES          RES    Client/Worker
28  WORK_DATA           REQ    Worker
28  WORK_DATA           RES    Client
29  WORK_WARNING        REQ    Worker
29  WORK_WARNING        RES    Client
30  GRAB_JOB_UNIQ       REQ    Worker
31  JOB_ASSIGN_UNIQ     RES    Worker
32  SUBMIT_JOB_HIGH_BG  REQ    Client
33  SUBMIT_JOB_LOW      REQ    Client
34  SUBMIT_JOB_LOW_BG   REQ    Client
35  SUBMIT_JOB_SCHED    REQ    Client
36  SUBMIT_JOB_EPOCH    REQ    Client