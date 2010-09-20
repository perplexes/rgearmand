require 'ip_address'
require 'queue'
require 'auth'

module Rgearmand
  class GearmanServer
    include Authorization::InstanceMethods
  end
end