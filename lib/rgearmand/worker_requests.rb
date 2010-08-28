module Rgearmand
  module WorkerRequests
    # 1   CAN_DO              REQ    Worker
    def can_do(func_name)
      unless WORKERS.has_key?(func_name) 
        WORKERS[func_name] = []
      end

      unless @capabilities.include?(func_name)
        @capabilities << func_name
      end

      WORKERS[func_name] << self

      logger.debug "Workers"
      logger.debug "-------"
      logger.debug WORKERS.inspect
    end

    # 2   CANT_DO             REQ    Worker
    def cant_do(func_name)
      logger.debug "Unregistering #{func_name}"
      WORKERS[func_name].delete self
      @capabilities.delete func_name
    end

    # 3   RESET_ABILITIES     REQ    Worker
    def reset_abilities
      @capabilities.each do |cap|
        cant_do cap
      end
    end

    # 4   PRE_SLEEP           REQ    Worker
    def pre_sleep; end

    # 9   GRAB_JOB            REQ    Worker
    def grab_job(unique = false)
      @capabilities.each do |capability|
        [:high, :normal, :low].each do |priority|
          next unless QUEUES.has_key?(capability)
          jobqueue = QUEUES[capability][priority]
          #logger.debug jobqueue.inspect
          if (jobqueue.size > 0) 
            job = jobqueue.next

            if job[:timestamp] == 0 || job[:timestamp] <= Time.now().to_i
              jobqueue.pop
              logger.debug job.inspect
              logger.debug "Found job: #{job.inspect}"

              if !JOBS.has_key? job[:job_handle]
                logger.debug "Adding to run queue..."
                JOBS[job[:job_handle]] = job
              end

              if unique
                respond :job_assign_uniq, job[:job_handle], capability, job[:uniq], job[:data]
              else 
                respond :job_assign, job[:job_handle], capability, job[:data]
              end

              return
            else 
              logger.debug "No jobs ready to run"
            end
          end
        end
      end

      logger.debug "No job!"
      respond :no_job
    end

    # 12  WORK_STATUS         REQ    Worker
    # 12  WORK_STATUS         RES    Client
    def work_status(job_handle, numerator, denominator)
      JOBS[job_handle][:numerator] = numerator
      JOBS[job_handle][:denominator] = denominator
    end

    # 13  WORK_COMPLETE       REQ    Worker
    # 13  WORK_COMPLETE       RES    Client
    def work_complete(job_handle, data)
      send_client :work_complete, job_handle, data
      dequeue job_handle
    end

    # 14  WORK_FAIL           REQ    Worker
    # 14  WORK_FAIL           RES    Client
    def work_fail(job_handle)
      send_client :work_complete, job_handle
      dequeue job_handle
    end

    # 22  SET_CLIENT_ID       REQ    Worker
    def set_client_id(worker_id = nil)
      if worker_id == nil
        worker_id = rand(36**8).to_s()
      end
      @worker_id = worker_id 
    end

    # 23  CAN_DO_TIMEOUT      REQ    Worker
    def can_do_timeout(func_name, timeout)
      throw :notimpl
    end

    # 24  ALL_YOURS           REQ    Worker(nyi)

    # 25  WORK_EXCEPTION      REQ    Worker
    # 25  WORK_EXCEPTION      RES    Client
    def work_exception(job_handle, data)
      send_client :work_exception, job_handle, data
      dequeue job_handle
    end

    # 26  OPTION_REQ          REQ    Client/Worker
    # 27  OPTION_RES          RES    Client/Worker
    def option_req(option_name)
      throw :notimpl
    end

    # 28  WORK_DATA           REQ    Worker
    # 28  WORK_DATA           RES    Client
    def work_data(job_handle, data)
      send_client :work_data, job_handle, data
    end

    # 29  WORK_WARNING        REQ    Worker
    # 29  WORK_WARNING        RES    Client
    def work_warning(job_handle, data)
      send_client :work_warning, job_handle, data
    end

    # 30  GRAB_JOB_UNIQ       REQ    Worker
    def grab_job_uniq
      throw :notimpl
    end
  end
end
