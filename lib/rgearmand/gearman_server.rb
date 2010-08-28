#require File.expand_path('manager', File.dirname(__FILE__))

class GearmanServer
  include Rgearmand::EmAdapter
  include Rgearmand::ClientRequests
  include Rgearmand::WorkerRequests
  include Rgearmand::WorkerQueue

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
      
      EventMachine::run {
        EventMachine::start_server "127.0.0.1", 4731, Rgearmand
        #Manager.run!({:port => 3000})
      }
    end

    


  end
end