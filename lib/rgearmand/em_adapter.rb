module Rgearmand
  module EmAdapter
    def initialize
      logger.info "Connection from someone..."
      @capabilities = []
      @currentjob = nil
      
      super
    end

    # Overrides for connections

    def post_init
      logger.debug "-- someone connected to regearmand!"
    end

    def unbind
      logger.debug "-- someone disconnected from regearmand!"
    end

    def parse_packets(data)
      if data[0] != 0
        logger.debug "control message <<< #{data.inspect}"
        if data[0..2] == "HA "
          logger.debug "ha message"
          args = data.split(" ")
          ha = args.shift
          cmd = "ha_#{args.shift.downcase}"
          hostname = args.shift
          (ip,port) = args.shift.split(":")
          
          if NEIGHBORS[hostname].nil?
            newnode = true
          else
            newnode = false
          end
          
          # Initialize if need be
          NEIGHBORS[hostname] ||= {}

          # Store their data
          NEIGHBORS[hostname][:ip] = ip
          NEIGHBORS[hostname][:port] = port
          NEIGHBORS[hostname][:new] = newnode
          
          self.send(cmd, hostname, *args)
          
        end
      else
        offset = 0
        while(offset < data.length)
          header = data[offset+0..offset+11]
          type = header[1..3].to_s
          cmd =  COMMANDS[header[4..7].unpack('N').first]
          datalen = header[8..11].unpack('N').first
          args = data[offset+12..offset+12+datalen].split("\0")

          offset = offset + datalen + 12

          logger.debug "Type: #{type}"
          logger.debug "Cmd: #{cmd}"
          logger.debug "Datalen: #{datalen}"
          logger.debug "Data: #{args}"

          yield cmd, args
        end        
      end
    end

    def receive_data(data)
      logger.debug "receive <<< #{data.inspect}"
      logger.debug "length <<< #{data.length}"

      parse_packets(data) do |cmd, args|
        self.send(cmd, *args)
      end
      
    end
    
    def generate(name, *args)
      args = args.flatten
      num = COMMAND_INV[name]
      arg = args.join("\0")
      data = [
        "\0",
        "RES",
        [num, arg.size].pack('NN'),
        arg
      ].join
    end

    def respond(type, *args)
      packet = generate(type, *args)
      logger.debug "response >>> #{packet.inspect}"
      send_data(packet)
    end
    
    def send_client(packet_type, job_handle, *args)
      packet = generate(packet_type, job_handle, args)
      if JOBS[job_handle]
        client = JOBS[job_handle][:client]
        client.andand.send_data(packet)
      else
        logger.debug "No client for job handle #{job_handle}..."
      end
    end
    
  end
end