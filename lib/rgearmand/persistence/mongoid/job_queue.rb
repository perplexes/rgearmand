class JobQueue
  include Mongoid::Document
  
  field :func_name

  def workers
    Worker.all_in(:function_names => [self.func_name]) 
  end
end
