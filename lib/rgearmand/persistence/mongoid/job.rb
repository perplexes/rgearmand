class Job
  include Mongoid::Document
  
  field :uniq
  field :func_name
  field :data
  field :timestamp, :type => Integer
  field :uniq
  field :job_handle
  field :priority
  field :enqueued_at, :type => Time
  field :started_at, :type => Time
  field :completed_at, :type => Time
  field :status, :type => String
  field :result, :type => String
  
  def job_queue
    JobQueue.find_or_create_by(:func_name => self.func_name)
  end
end
