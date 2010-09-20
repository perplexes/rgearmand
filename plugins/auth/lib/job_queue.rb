class JobQueue
  include Mongoid::Document
  
  field :name
  field :fqn
  # These are the client and worker IP addresses allowed to connect to this queue
  references_many :ip_addresses, :stored_as => Array, :inverse_of => :queue
  referenced_in :job
  
  validates_presence_of :name
  # before_save :set_fqn
  
  references_one :user, :inverse_of => :job_queues
  
  def set_fqn
    self.user.id + '.' + self.name
  end
end