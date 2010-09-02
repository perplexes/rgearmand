
require 'socket'
include Socket::Constants

module Rgearmand
  module Availability
   
    MAX_NODE_TIMEOUT = 10
    MAX_NODE_ERRORS = 2
    
    # HA command packets
    def ha_heartbeat(hostname, *args)
      time = args[0]
      logger.debug "Received heartbeat from #{hostname} at #{time}"
      update_neighbor_table(hostname, time)
      
      if NEIGHBORS[hostname][:new]
        logger.debug "New node..."
        # new node? get them up to speed!
        NEIGHBORS.each do |host, hostdata|
          next if host == hostname || host == HOSTNAME
          logger.debug("Sending #{hostname} info on #{host}")
          send_data("HA HEARTBEAT #{host} #{hostdata[:ip]}:#{hostdata[:port]} #{hostdata[:last_seen]}\n")
        end
        
        NEIGHBORS[hostname][:new] = false
        logger.debug "Done getting them up to speed."
      end
      
      send_data(".\n")
    end    
    
    def emit_heartbeat
      my_port = OPTIONS[:port]
      now = Time.now().to_i
      NEIGHBORS.each do |hostname, hostdata|
        
        next if hostdata[:status] == :dead
        
        ip = hostdata[:ip]
        port = hostdata[:port].to_i

        begin
          logger.debug("Host data: #{hostdata.inspect}")
          socket = Socket.new( AF_INET, SOCK_STREAM, 0 )
          sockaddr = Socket.pack_sockaddr_in( port, ip )
          socket.connect( sockaddr )
          logger.debug "Notifying #{hostname} at #{ip}:#{port} that we're alive..."
          # TODO: How shall we decide which IP to advertise? gethostbyname() for our hostname?
          socket.puts( "HA HEARTBEAT #{HOSTNAME} 127.0.0.1:#{my_port} #{now}\n" )
          response = socket.gets
          logger.debug "Received: #{response}"
          self.receive_data(response)
          socket.close
        rescue => ex
          logger.debug "Error: #{ex.inspect}"
          hostdata[:error_count] ||= 0
          hostdata[:error_count] += 1
          if hostdata[:error_count] > MAX_NODE_ERRORS
            logger.debug "Too many failure connecting to #{hostname} at #{ip}:#{port}, BRING OUT YE' DEAD!"
            hostdata[:status] = :dead
          else
            logger.debug "Problems connecting to #{hostname} at #{ip}:#{port}, assuming transient for the moment..."
          end
        end
      end
    end
    
    def update_neighbor_table(hostname, time)
      NEIGHBORS[hostname] ||= {}
      
      NEIGHBORS[hostname][:status] = :alive
      NEIGHBORS[hostname][:last_seen] = time
      # TODO: 
      # 1. Check if neighbor has flipped from dead to alive
      # 2. True? Relinquish any jobs we stole from them back to their queue
      # 3. Notify our neighbors that he's back up.
    end
    
    def prune_neighbor_table
      now = Time.now().to_i
      
      NEIGHBORS.each do |hostname, hostdata|
        last_seen = hostdata[:last_seen]
        time_lapsed = now - last_seen
        if hostdata[:status] == :alive && time_lapsed > MAX_NODE_TIMEOUT
          # Assume neighbor is dead, and assume their jobs
          logger.debug "#{hostname} last seen #{time_lapsed} seconds ago (max: #{MAX_NODE_TIMEOUT}), declaring dead!"
          NEIGHBORS[hostname][:status] = :dead
          # Consume jobs (put up for vote!)
        end
      end
    end
    
    def declare_neighbor_dead(hostname)
      # Do stuff...
    end
    
  end
end