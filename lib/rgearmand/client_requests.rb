module Rgearmand
  module ClientRequests
    # 7   SUBMIT_JOB          REQ    Client
    def submit_job(func_name, uniq, data)
      job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :persist => true)

      JOBS[job_handle] = {:client => self , :uniq => uniq}
      respond :job_created, job_handle

      WORKERS.has_key?(func_name) && WORKERS[func_name].each do |w|
        logger.debug "Sending NOOP to #{w}"
        packet = generate :noop
        w.send_data(packet)
      end
    end

    # 15  GET_STATUS          REQ    Client
    def get_status(job_handle)
      unless JOBS[job_handle][:numerator].nil?
        # We have status, so send it off
        numerator = JOBS[job_handle][:numerator]
        denominator = JOBS[job_handle][:denominator]
        packet = generate :status_res, job_handle, 1, 0, numerator, denominator 
      else
        # We don't have a status for this packet
        packet = generate :status_res, job_handle, 0, 0, 0, 0
      end
    end

    # 16  ECHO_REQ            REQ    Client/Worker
    # 17  ECHO_RES            RES    Client/Worker
    def echo_req(data)
      send_client :echo_res, data
    end

    # 18  SUBMIT_JOB_BG       REQ    Client
    def submit_job_bg(func_name, uniq, data)
      job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :persist => true)
      respond :job_created, job_handle
    end

    # 19  ERROR               RES    Client/Worker(notimpl)
    # 20  STATUS_RES          RES    Client(notimpl)

    # 21  SUBMIT_JOB_HIGH     REQ    Client
    def submit_job_high(func_name, uniq, data)
      throw :notimpl
    end

    # 32  SUBMIT_JOB_HIGH_BG  REQ    Client
    def submit_job_high_bg(func_name, uniq, data)
      throw :notimpl
    end

    # 33  SUBMIT_JOB_LOW      REQ    Client
    def submit_job_low(func_name, uniq, data)
      throw :notimpl
    end

    # 34  SUBMIT_JOB_LOW_BG   REQ    Client
    def submit_job_low_bg(func_name, uniq, data)
      throw :notimpl
    end

    # 35  SUBMIT_JOB_SCHED    REQ    Client
    def submit_job_sched(func_name, uniq, data)
      throw :notimpl
    end

    # 36  SUBMIT_JOB_EPOCH    REQ    Client
    def submit_job_epoch(func_name, uniq, epoch, data)
      logger.debug "Epoch job submission"
      job_handle = enqueue(:func_name => func_name, :uniq => uniq, :data => data, :timestamp => epoch, :persist => true)
      respond :job_created, job_handle
    end
  end
end

