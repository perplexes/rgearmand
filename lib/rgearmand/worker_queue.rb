require 'set'
module Rgearmand
  class WorkerQueue
    attr_reader :workers, :capabilities, :hostname
    attr_writer :persistent_queue
    def initialize(hostname = `hostname`.chomp)
      # Jobs to run
      # :low => PQueue
      # :normal => PQueue
      # :high => PQueue
      @queues = {}
      
      # Jobs being run currently, indexed by job_handle
      @jobs = {}
      
      # A unique id holder
      @state_id = 0
      
      # Worker connections indexed by function name
      @workers = {}
      
      # Inverse of @workers, which lists capabilities for a given worker.
      @worker_by_connection = {}
      
      @hostname = hostname
    end
    
    def get_job_handle
      "H:#{@hostname}:#{$$}:#{@state_id += 1}"
    end
    
    # Add a job to the running queue.
    def add(job_handle, options)
      @jobs[job_handle] = options
    end
    
    def each_worker(func_name, &block)
      return unless @workers.has_key?(func_name)
      @workers[func_name].each(&block)
    end
    
    def status(job_handle)
      return [0,0,0,0] unless @jobs.has_key?(job_handle)
      return [0,0,0,0] if @jobs[job_handle][:numerator].nil?
      
      # We have status, so send it off
      numerator = @jobs[job_handle][:numerator]
      denominator = @jobs[job_handle][:denominator]
      [1, 0, numerator, denominator]
    end
    
    def set_status(job_handle, numerator, denominator)
      @jobs[job_handle][:numerator] = numerator
      @jobs[job_handle][:denominator] = denominator
    end
    
    def client(job_handle)
      if !@jobs.has_key?(job_handle)
        return logger.debug "No job handle #{job_handle}..."
      end
      
      if !@jobs[job_handle].has_key?(:client)
        return logger.debug "No client for job handle #{job_handle}..."
      end
      
      yield @jobs[job_handle][:client]
    end
    
    def can_do(func_name, connection)
      @workers[func_name] ||= []
      @workers[func_name] << connection
    end
    
    def cant_do(func_name, connection)
      return if !@workers.has_key?(func_name)
      
      @workers[func_name].delete(connection)
    end
    
    # XXX: Clean this?
    def grab_job(capabilities)
      capabilities.each do |cap|
        queues = @queues[cap] || {}
          [:high, :normal, :low].each do |priority|
          next unless queues.has_key?(priority)

          job_queue = queues[priority]
          if job_queue.size == 0
            logger.debug "No jobs ready to run in #{priority} priority."
            next
          end

          job = job_queue.next
          next if !capabilities.include?(job[:func_name])
          if job[:timestamp] == 0 || job[:timestamp] <= Time.now().to_i
            job_queue.pop
            logger.debug job.inspect
            logger.debug "Found job: #{job.inspect}"

            if !@jobs.has_key?(job[:job_handle])
              logger.debug "Adding to run queue..."
              @jobs[job[:job_handle]] = job
            end

            return job
          end
        end
      end
      
      nil
    end
    
    def enqueue(opts = {})
      func_name = opts[:func_name] || opts["func_name"]
      priority = opts[:priority] || opts["priority"] || :normal
      uniq = opts[:uniq] || opts["uniq"] 
      job_handle = get_job_handle
      data = opts[:data] || opts["data"] 
      timestamp = opts[:timestamp] || opts["timestamp"] || 0

      unless @queues.has_key?(func_name) 
        @queues[func_name] = { 
          :normal => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 }, 
          :high => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 }, 
          :low => Containers::PriorityQueue.new() { |y, x| (x <=> y) == 1 } 
        }
      end

      logger.debug "Timestamp: #{timestamp} -> #{timestamp.to_i}"
      @queues[func_name][priority].push({:uniq => uniq, :func_name => func_name, :job_handle => job_handle, :data => data, :timestamp => timestamp.to_i}, timestamp.to_i)

      if opts[:persist]
        logger.debug "Persisting!"
        @persistent_queue.store!(func_name, data, uniq, timestamp)
      end 
      
      job_handle
    end

    def dequeue(job_handle)
      @persistent_queue.delete!(@jobs[job_handle][:uniq])
      @jobs.delete(job_handle)
    end
  end
end