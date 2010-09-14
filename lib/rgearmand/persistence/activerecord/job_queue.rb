class JobQueue < ActiveRecord::Base
  has_many :jobs
end