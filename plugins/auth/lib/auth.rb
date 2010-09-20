module Rgearmand
  module Authorization
    module InstanceMethods
      def receive_data(data)
        port, *addr = get_peername[2,6].unpack("nC4")
        if ip_address = IpAddress.first(:conditions => {:address => addr})
          super
        else
          respond :error, "Unknown IP Address. Please enter #{addr.join('.')} into your queue's ACL."
          close_connection(false)
        end
      end
    end
  end
end