#require File.expand_path('manager', File.dirname(__FILE__))
require 'set'
require 'rgearmand/client_requests'
require 'rgearmand/worker_requests'
require 'rgearmand/em_adapter'
require 'rgearmand/worker_queue'
require 'rgearmand/persistence/base'
require 'rgearmand/persistence/redis'
require 'rgearmand/persistence/mongodb'

module Rgearmand
  class GearmanServer < EventMachine::Connection
    include Rgearmand::EmAdapter
    include Rgearmand::ClientRequests
    include Rgearmand::WorkerRequests
  
    def initialize
      @capabilities = Set.new
    end
    
    def self.worker_queue
      @worker_queue
    end
    
    def worker_queue
      self.class.worker_queue
    end
  
    def self.start
      @hostname = `hostname`.chomp
      @port = nil
      @worker_queue = WorkerQueue.new(@hostname)
      #@persistent_queue = PersistentQueue::RedisQueue.new(@worker_queue, :host => "127.0.0.1", :port => 6379, :hostname => @hostname)
      @persistent_queue = PersistentQueue::MongoDBQueue.new(@worker_queue, :host => "127.0.0.1", :port => 27017, :hostname => @hostname)
      
      EventMachine::run {
        logger.info "Starting server on #{OPTIONS[:ip]}:#{OPTIONS[:port]}"
        EventMachine::start_server OPTIONS[:ip], OPTIONS[:port], self
        Rgearmand.call_after_inits
      }
    end
  end
end