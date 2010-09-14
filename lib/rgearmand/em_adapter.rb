module Rgearmand
  module EmAdapter
    def initialize
      logger.info "Connection from someone..."
      @capabilities = []
      @currentjob = nil
      @type = nil
      super
    end

    # Overrides for connections

    def post_init
      logger.debug "-- someone connected to regearmand!"
    end

    def unbind
      if @type == :worker
        logger.debug "-- a worker disconnected!"
        
        w = Worker.find(:first, :conditions => {:worker_id => @worker_id})
        if w != nil
          logger.debug "Found worker: #{w.inspect}"
          w.destroy
        end
      else
        logger.debug "-- a client disconnected!"
      end
    end

    def parse_packets(data)
      if data[0] != 0
        logger.debug "control message <<< #{data.inspect}"
        Rgearmand.control_packet(data)
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
      worker_queue.client(job_handle){|c| c.send_data packet}
    end
    
  end
end