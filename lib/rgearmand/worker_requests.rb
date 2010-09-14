module Rgearmand
  module WorkerRequests
    # 1   CAN_DO              REQ    Worker
    def can_do(func_name)
      return if @capabilities.include? func_name
      
      # Record worker
      worker = Worker.find_or_create_by(:worker_id => @worker_id)
      worker.function_names ||= [] 
      worker.function_names << func_name
      logger.debug "Worker capabilities: #{worker.inspect}"
      worker.save
      
      @capabilities << func_name
      worker_queue.can_do(func_name, self)

      logger.debug "Workers"
      logger.debug "-------"
      logger.debug worker_queue.workers.inspect
    end

    # 2   CANT_DO             REQ    Worker
    def cant_do(func_name)
      logger.debug "Unregistering #{func_name}"
      worker_queue.cant_do(func_name, self)
      @capabilities.delete(func_name)
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
      if job = worker_queue.grab_job(@capabilities)
        if unique
          respond :job_assign_uniq, job[:job_handle], job[:func_name], job[:uniq], job[:data]
        else 
          respond :job_assign, job[:job_handle], job[:func_name], job[:data]
        end
      else
        logger.debug "No job!"
        respond :no_job
      end
      
      logger.debug "Handed out job"
    end

    # 12  WORK_STATUS         REQ    Worker
    # 12  WORK_STATUS         RES    Client
    def work_status(job_handle, numerator, denominator)
      worker_queue.set_status(numerator, denominator)
    end

    # 13  WORK_COMPLETE       REQ    Worker
    # 13  WORK_COMPLETE       RES    Client
    def work_complete(job_handle, data)
      send_client :work_complete, job_handle, data
      
      job = worker_queue.dequeue job_handle
      job.status = "Success"
      job.result = data
      job.save
      
      
    end

    # 14  WORK_FAIL           REQ    Worker
    # 14  WORK_FAIL           RES    Client
    def work_fail(job_handle)
      send_client :work_fail, job_handle

      job = worker_queue.dequeue job_handle
      job.status = "Failed"
      job.save

    end

    # 22  SET_CLIENT_ID       REQ    Worker
    def set_client_id(worker_id = nil)
      if worker_id.nil?
        worker_id = rand(36**8).to_s()
      end
      @worker_id = worker_id
      @type = :worker
    end

    # 23  CAN_DO_TIMEOUT      REQ    Worker
    def can_do_timeout(func_name, timeout)
      throw :notimpl
    end

    # 24  ALL_YOURS           REQ    Worker(nyi)

    # 25  WORK_EXCEPTION      REQ    Worker
    # 25  WORK_EXCEPTION      RES    Client
    def work_exception(job_handle, data = nil)
      send_client :work_exception, job_handle, data

      job = worker_queue.dequeue job_handle
      job.status = "Exception"
      job.result = data
      job.save
      
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
