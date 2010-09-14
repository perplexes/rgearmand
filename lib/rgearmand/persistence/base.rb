module Rgearmand
  class PersistentQueue;end
  class PersistentQueue::Base
    def initialize(worker_queue)
      @worker_queue = worker_queue
      @worker_queue.persistent_queue = self
      start_time = Time.now
      count = load!
      end_time = Time.now
      load_time = end_time - start_time
      rate = count / load_time rescue 0
      logger.debug "Loaded #{count} persisted jobs in #{sprintf('%.2f', load_time)} seconds (#{rate} jobs per sec.)!"
      
    end
    
    def load!
      throw :subclass_impl
    end
    
    def store!
      throw :subclass_impl
    end
    
    def delete!
      throw :subclass_impl
    end
  end
end