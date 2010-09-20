class IpAddress
  include Mongoid::Document
  field :address, :type => Array
  validates_presence_of :address
  references_one :job_queue, :inverse_of => :ip_addresses
  
  def address=(val)
    val = val.split('.') if val.is_a?(String)
    if val.is_a?(Array)
      val = val.map(&:to_i)
    else
      raise "Unrecognized value type here: #{val.inspect}"
    end
  end
end