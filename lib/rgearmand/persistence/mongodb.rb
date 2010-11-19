module Rgearmand
  class PersistentQueue
    class MongoDBQueue < Base
      def initialize(queue, options = {:hostname => `hostname`.chomp, :host => "127.0.0.1", :port => 27017, :persist => true})
        @hostname = options[:hostname]
        @db = Mongo::Connection.new("localhost", 27017).db("gearman")
        @persist = true
        @collection = @db.collection(@hostname)
  
        super queue
      end
    
      def load!
        # LOAD
        # Read jobs from the persistent queue
        logger.debug "Loading jobs from mongo"
        count = 0
        start_time = Time.now
        @collection.find().each do |job| 
          puts job.inspect
          job_handle = @worker_queue.enqueue(job)
          count += 1
        end
        
        count
      end
    
      def store!(func_name, data, uniq, timestamp)
        logger.debug "MongoDBQueue.store!"
        return true unless @persist
      
        logger.debug "Storing job in MongoDB"
        doc = {
          :func_name => func_name,
          :data => data,
          :uniq => uniq,
          :timestamp => timestamp
        }
        
        @collection.insert(doc)
      end
    
      def delete!(uniq)
        @collection.remove({"uniq"=> uniq}) 
      end
    end # Redis < Base
  end # PersistentQueue
end # Rgearmand