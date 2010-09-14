class Job < ActiveRecord::Base
  belongs_to :job_queue
end
