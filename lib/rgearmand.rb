begin
  # Require the preresolved locked set of gems.
  require File.expand_path('/../../.bundle/environment', __FILE__)
rescue LoadError
  puts "loaderror"
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"

  Bundler.setup(:default, GEARMAN_ENV.to_sym)
end

require 'redis'
require 'algorithms'
require 'ruby-debug'
require 'andand'
require 'eventmachine'


class Containers::Heap
  def stored
    @stored
  end
end

class Containers::PriorityQueue
  def to_a
    @heap.stored.collect{ |element|  {:key => element[0], :value => element[1][0].value}  }
  end
end

$: << File.dirname(__FILE__)
Debugger.start if GEARMAN_ENV == 'development'

COMMANDS = {
  1  => :can_do,               # W->J: FUNC
  2  => :cant_do,              # W->J: FUNC
  3  => :reset_abilities,      # W->J: --
  4  => :pre_sleep,            # W->J: --
  #5 =>  (unused),             # -      -
  6  => :noop,                 # J->W: --
  7  => :submit_job,           # C->J: FUNC[0]UNIQ[0]ARGS
  8  => :job_created,          # J->C: HANDLE
  9  => :grab_job,             # W->J: --
  10 => :no_job,               # J->W: --
  11 => :job_assign,           # J->W: HANDLE[0]FUNC[0]ARG
  12 => :work_status,          # W->J/C: HANDLE[0]NUMERATOR[0]DENOMINATOR
  13 => :work_complete,        # W->J/C: HANDLE[0]RES
  14 => :work_fail,            # W->J/C: HANDLE
  15 => :get_status,           # C->J: HANDLE
  16 => :echo_req,             # ?->J: TEXT
  17 => :echo_res,             # J->?: TEXT
  18 => :submit_job_bg,        # C->J: FUNC[0]UNIQ[0]ARGS
  19 => :error,                # J->?: ERRCODE[0]ERR_TEXT
  20 => :status_res,           # C->J: HANDLE[0]KNOWN[0]RUNNING[0]NUM[0]DENOM
  21 => :submit_job_high,      # C->J: FUNC[0]UNIQ[0]ARGS
  22 => :set_client_id,        # W->J: [RANDOM_STRING_NO_WHITESPACE]
  23 => :can_do_timeout,       # W->J: FUNC[0]TIMEOUT
  24 => :all_yours,            # REQ    Worker
  25 => :work_exception,       # W->J: HANDLE[0]ARG
  26 => :option_req,           # C->J: TEXT
  27 => :option_res,           # J->C: TEXT
  28 => :work_data,            # REQ    Worker
  29 => :work_warning,         # W->J/C: HANDLE[0]MSG
  30 => :grab_job_uniq,        # REQ    Worker
  31 => :job_assign_uniq,      # RES    Worker
  32 => :submit_job_high_bg,   # C->J: FUNC[0]UNIQ[0]ARGS
  33 => :submit_job_low,       # C->J: FUNC[0]UNIQ[0]ARGS
  34 => :submit_job_low_bg,    # C->J: FUNC[0]UNIQ[0]ARGS
  35 => :submit_job_sched,     # REQ    Client
  36 => :submit_job_epoch      # C->J: FUNC[0]UNIQ[0]EPOCH[0]ARGS
}
COMMAND_INV = COMMANDS.invert

PRIORITIES = {
  1 => :high, 
  2 => :normal, 
  3 => :low
}

PQUEUE = Redis.new(:host => "127.0.0.1", :port => 6379)
QUEUES = {}
WORKERS = {}
STATE = {}
JOBS = {}
CLIENTS = {}
NEIGHBORS = {}
HOSTNAME = ARGV[0]

# Signals
Signal.trap('INT') { EM.stop }
Signal.trap('TERM'){ EM.stop }

require 'rgearmand/client_requests'
require 'rgearmand/worker_requests'
require 'rgearmand/em_adapter'
require 'rgearmand/worker_queue'
require 'rgearmand/gearman_server'
require 'rgearmand/manager'

# TODO: Need a round-robin queue for workers.
module Rgearmand
  include Rgearmand::EmAdapter
  include Rgearmand::ClientRequests
  include Rgearmand::WorkerRequests
  include Rgearmand::WorkerQueue
end
