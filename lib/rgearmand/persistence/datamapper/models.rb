class Job
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
	property :uniq,         String
  property :data,         String
  property :timestamp,    Integer
  property :job_handle,   String
  property :enqueued_at,  DateTime
  property :started_at,   DateTime
  property :completed_at, DateTime
  property :status,       String
  property :result,       String
  property :server,       String
  belongs_to :job_queue
end

class JobQueue
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String

end

class Worker
  include DataMapper::Resource

  property :id,         Serial
  property :worker_id,  String
end

