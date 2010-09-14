require 'rgearmand/persistence/datamapper/models'

DataMapper::Logger.new($stdout, :error)
#DataMapper.setup(:default, 'postgres://mort.local/gearman_development')
DataMapper.setup(:default, 'sqlite:///Users/jewart/Code/Ruby/rgearmand/gearman_development.sqlite3')
DataMapper.finalize

module Rgearmand
  class PersistentQueue
    class DataMapperQueue < Base

      def initialize(queue, options = {:hostname => `hostname`.chomp})
        @hostname = options[:hostname]
        @persist = true
        @job_queue = JobQueue.first_or_create({:name => "reverse_string"})

        super queue
      end

      def load!
        # LOAD
        # Read jobs from the persistent queue
        count = 0
        Job.all(:server => @hostname).each do |job| 
          job_handle = @worker_queue.enqueue(job.attributes)
          #logger.debug "Enqueued with handle #{job_handle}"
          count += 1
        end
        count
      end

      def store!(func_name, data, uniq, timestamp)
        logger.debug "DataMapperQueue.store!"
        return true unless @persist


        job = Job.create(
          :uniq => uniq,
          :job_queue => @job_queue,
          :server => @hostname,
          :data => data,
          :uniq => uniq,
          :timestamp => timestamp
        )
        
        logger.debug "Storing job in DataMapperQueue "
        return job
      end

      def delete!(uniq)
        @collection.remove({"uniq"=> uniq}) 
      end
   
    end
  end
end