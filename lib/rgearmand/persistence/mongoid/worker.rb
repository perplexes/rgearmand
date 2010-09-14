class Worker
  include Mongoid::Document

  field :worker_id
  field :function_names, :type => Array
end
