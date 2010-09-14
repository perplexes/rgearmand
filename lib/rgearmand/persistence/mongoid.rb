require 'rgearmand/persistence/mongoid/models'

file_name = File.join(APP_ROOT, "config", "mongoid.yml")
@settings = YAML.load(ERB.new(File.new(file_name).read).result)

Mongoid.configure do |config|
  config.from_hash(@settings['development'])
end

module Rgearmand
  class PersistentQueue
    class MongoidDBQueue < Base
      def initialize(queue, options = {:hostname => `hostname`.chomp, :host => "127.0.0.1", :port => 27017, :persist => true})
        @hostname = options[:hostname]
        @persist = true
        @job_queues = {}
        super queue
      end
    
      def load!
        # LOAD
        # Read jobs from the persistent queue
        logger.debug "Loading data from MongoDB using Mongoid"
        count = 0
        Job.find(:all, :conditions => { :server => @hostname, :completed_at => nil }).each do |job|
          job_handle = @worker_queue.enqueue_job(job)
          logger.debug "Enqueued with handle #{job_handle}"
          count += 1
        end
        count
      end
    
      def store!(func_name, data, uniq, timestamp, priority, job_handle)
        logger.debug "MongoidDBQueue.store!"
        return true unless @persist
      
        @job_queues[func_name] ||= JobQueue.find_or_create_by(:func_name => func_name)
        job_queue = @job_queues[func_name]
        
        job = Job.create(
          :func_name => func_name,
          :server => @hostname,
          :job_handle => job_handle,
          :data => data,
          :uniq => uniq,
          :timestamp => timestamp, 
          :enqueued_at => Time.now(), 
          :priority => priority
        )
              
        logger.debug "Storing job in MongoDB via Mongoid"
        
        return job
      end
    
      def delete!(uniq)
        job = Job.find(:first, :conditions => {:uniq => uniq})
        job.completed_at = Time.now()
        job.save
      end
    end # MongoidDBQueue < Base
  end # PersistentQueue
end # Rgearmand