module Rgearmand
  class PersistentQueue;end
  class PersistentQueue::Base
    def initialize(worker_queue)
      @worker_queue = worker_queue
      @worker_queue.persistent_queue = self
      load!
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