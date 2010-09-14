class Worker < ActiveRecord::Base
  has_many :job_queues
end