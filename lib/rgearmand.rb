require 'rubygems'
require 'eventmachine'
require 'ruby-debug'
Debugger.start

TYPE_TABLE = {}
NUM_TABLE = {}

TYPE_TABLE = DATA.read.each_line do |l|
  next h if l =~ /#/
  num, name, magic, type = l.split
  TYPE_TABLE[[magic, num.to_i]] = name
  NUM_TABLE[[magic, name]] = num.to_i
end

# TODO: Need a round-robin queue for workers.
module Rgearmand
  def initialize
    puts "RGearmanD up"
    super
  end
  
  def post_init
    puts "-- someone connected to regearmand!"
  end
  
  def unbind
    puts "-- someone disconnected from regearmand!"
  end

  def receive_data(data)
    puts "receive <<< #{data.inspect}"
    magic = data[1..3]
    num, len = data[4..11].unpack("NN")
    name = TYPE_TABLE[[magic, num]]
    arguments = data[12..-1].split("\0")
    puts "#{magic}, #{num}, #{len}, #{name}, #{arguments.inspect}"
    
    self.send(name.downcase, *arguments)
  end
  
  def respond(name, *args)
    magic = 'RES'
    num = NUM_TABLE[[magic,name.to_s.upcase]]
    arg = args.join("\0")
    data = [
      "\0",
      magic,
      [num, arg.size].pack('NN'),
      arg
    ].join
    puts "response >>> #{data.inspect}"
    send_data(data)
  end
  
  def submit_job(func_name, uniq, data)
    respond :job_created, "H:lap:1"
    respond :work_complete, "H:lap:1", data.reverse
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 4730, Rgearmand
}

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