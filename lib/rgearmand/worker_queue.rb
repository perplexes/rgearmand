module Rgearmand
  module WorkerQueue
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
  end
end