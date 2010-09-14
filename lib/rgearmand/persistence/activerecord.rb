require 'rgearmand/persistence/activerecord/models'
require 'active_record'

db_config_file = File.join(APP_ROOT, "config", "database.yml")
dbconfig = YAML::load(ERB.new(File.new(db_config_file).read).result)
ActiveRecord::Base.establish_connection(dbconfig["development"])
ActiveRecord::Base.logger = Logger.new(STDOUT)

module Rgearmand
  class PersistentQueue
    class ActiveRecordQueue < Base

      def initialize(queue, options = {:hostname => `hostname`.chomp})
        @hostname = options[:hostname]
        @persist = true
        @job_queue = JobQueue.find_or_create_by_name("reverse_string")

        super queue
      end

      def load!
        # LOAD
        # Read jobs from the persistent queue
        count = 0
        Job.find(:all, :conditions => {:server => @hostname} ).each do |job| 
          #puts job.attributes.inspect
          job_handle = @worker_queue.enqueue(job.attributes)
          #logger.debug "Enqueued with handle #{job_handle}"
          count += 1
        end
        count
      end

      def store!(func_name, data, uniq, timestamp)
        logger.debug "ActiveRecordQueue.store!"
        return true unless @persist


        job = Job.create(
          :uniq => uniq,
          :job_queue => @job_queue,
          :server => @hostname,
          :data => data,
          :uniq => uniq,
          :timestamp => timestamp
        )
        
        logger.debug "Storing job in AR DB"
        return job
      end

      def delete!(uniq)
        @collection.remove({"uniq"=> uniq}) 
      end
   
    end
  end
end