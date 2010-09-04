module Rgearmand
  class PersistentQueue
    class RedisQueue < Base
      def initialize(queue, options = {:hostname => `hostname`.chomp, :host => "127.0.0.1", :port => 6379, :persist => true})
        @hostname = options[:hostname]
        @persist = options.delete(:persist)
        @redis = Redis.new(options)
        super queue
      end
    
      def load!
        # LOAD
        # Read jobs from the persistent queue
        @redis.smembers(@hostname).andand.each do |key|
          logger.debug "Found key: #{key}"
          if @redis.exists(key)
            jdata = @redis.get(key)
            logger.debug "Found data: #{jdata}"
            if jdata.nil?
              logger.debug "Empty data, removing key... "
              result = @redis.del(key)
              logger.debug "Deleted #{result} keys"
            else 
              job = JSON.parse(jdata)
              logger.debug "Job: #{job}"
              if job[:uniq].nil?
                job[:uniq] = key.split("-")[1]
              end
              job_handle = @queue.enqueue(job)
              logger.debug "Enqueued with handle #{job_handle}"
            end
          else
            logger.debug "Empty job, removing key."
            @redis.srem @hostname, key
          end
        end
      end
    
      def store!(func_name, data, uniq, timestamp)
        return true unless @persist
      
        key = "#{@hostname} - #{uniq}"
        value = JSON.generate({
          :func_name => func_name,
          :data => data,
          :uniq => uniq,
          :timestamp => timestamp})
      
        @redis.set key, value
        @redis.sadd hostname, key
      end
    
      def delete!(uniq)
        key = "#{@hostname}-#{uniq}"
        logger.debug "Checking for #{key} in persistent queue"
        if @redis.sismember(@hostname, key)
          if !@redis.exists key 
            logger.debug "Removing job from persistent queue"
            @redis.del key
          end
          @redis.srem @hostname, key
        end
      end
    end # Redis < Base
  end # PersistentQueue
end # Rgearmand