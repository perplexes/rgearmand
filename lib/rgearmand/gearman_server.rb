#require File.expand_path('manager', File.dirname(__FILE__))

class GearmanServer
  include Rgearmand::EmAdapter
  include Rgearmand::ClientRequests
  include Rgearmand::WorkerRequests
  include Rgearmand::WorkerQueue
  include Rgearmand::Availability 
  
  def initialize
  end
  
  def start
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
    
    EventMachine::run {
      logger.info "Starting server on #{OPTIONS[:ip]}:#{OPTIONS[:port]}"
      EventMachine::start_server OPTIONS[:ip], OPTIONS[:port], Rgearmand

      if OPTIONS[:puppetmaster]
        (nodename, ip, port) = OPTIONS[:puppetmaster].split(":")
        NEIGHBORS[nodename] = { :ip => ip, :port => port }
      end
      
      timer = EventMachine::PeriodicTimer.new(5) do
         self.emit_heartbeat
      end

    }

    


  end
end