=begin
%%{

machine gearman;
alphtype int;

action headmark { 
puts "headmark: #{p}"
puts "D: #{data[p-1]}"
puts data
start = p 
}

action magicmark { 
puts "magicmark: #{p}"
puts "D: #{data[p]} #{data[p+1]} #{data[p+2]} #{data[p+3]}"
puts data
start = p 
}

action sizemark { 
puts "sizemark: #{p}"
start = p 
}

action datamark { 
puts "datamark: #{p}"
start = p 
}

action magic {
puts "Packet #: #{packetnum}"
packets << {}
magic = data[start..p-1].unpack('N').first
packets[packetnum][:magic] = COMMANDS[magic]
}

action size {
puts "Size: #{p}"
size = data[start..p-1].unpack('N').first
packets[packetnum][:size] = size
}

action data {
puts "num: #{packetnum}"
pkt = packets[packetnum]
pkt ||= {}

puts "P: #{pkt.inspect}"
puts "S: #{start} -- #{packets[packetnum][:size]}"
data_end = start + (packets[packetnum][:size] - 1)
packets[packetnum][:data] = data[start..data_end]
if packets[packetnum][:size] != (packets[packetnum][:data] && packets[packetnum][:data].size)
packets[packetnum][:error] = "Size is invalid. Expected #{packets[packetnum][:size]} bytes, but have #{packets[packetnum][:data].size}."
else
packets[packetnum][:arguments] = packets[packetnum][:data].split("\0")
end

puts "P: #{pkt.inspect}"
puts "S: #{start}"
p = data_end + 1
puts "Ptr: #{p}"
packetnum += 1
}

action packet_error {
packets[packetnum] ||= {}
packets[packetnum][:packet_valid] = false
}

action size_error {
if p == 8
packets[packetnum][:error] = "Size header not found."
else
packets[packetnum][:error] = "Size invalid: #{data[start..p-1].inspect}"
end
}

action magic_error {
puts "NARFLE"
packets[packetnum][:error] = "Magic header invalid: #{data[start..p-1].inspect}."
}

size        = (0..255){4};
size_cap    = size >sizemark %size @err(size_error);

req_head    = 0 . 'REQ';
req_head_cap = req_head >headmark;
res_head    = (0 . 'RES');


req_magic   = (0{3} . (1|2|3|4|7|9|12|13|14|15|16|18|21|22|23|24|25|26|28|29|30|32|33|34|35|36));
res_magic   = (0{3} . (6|8|10|11|12|13|14|17|19|20|25|27|28|29|31));
req_magic_cap = req_magic >magicmark %magic @err(magic_error);
res_magic_cap = res_magic >magicmark %magic @err(magic_error);

data        = (any*  - (req_head | res_head));
data_cap    = (data >datamark %data);

req_packet  = (req_head_cap . req_magic_cap . size_cap . data_cap);
res_packet  = (res_head . res_magic_cap . size_cap . data_cap);
packet      = (req_packet | res_packet);
packets     = packet+;

main := packets;

}%%
=end


module Rgearmand
  class Protocol
    COMMANDS = {
      1  => :can_do,               # W->J: FUNC
      2  => :cant_do,              # W->J: FUNC
      3  => :reset_abilities,      # W->J: --
      4  => :pre_sleep,            # W->J: --
      #5 =>  (unused),             # -      -
      6  => :noop,                 # J->W: --
      7  => :submit_job,           # C->J: FUNC[0]UNIQ[0]ARGS
      8  => :job_created,          # J->C: HANDLE
      9  => :grab_job,             # W->J: --
      10 => :no_job,               # J->W: --
      11 => :job_assign,           # J->W: HANDLE[0]FUNC[0]ARG
      12 => :work_status,          # W->J/C: HANDLE[0]NUMERATOR[0]DENOMINATOR
      13 => :work_complete,        # W->J/C: HANDLE[0]RES
      14 => :work_fail,            # W->J/C: HANDLE
      15 => :get_status,           # C->J: HANDLE
      16 => :echo_req,             # ?->J: TEXT
      17 => :echo_res,             # J->?: TEXT
      18 => :submit_job_bg,        # C->J: FUNC[0]UNIQ[0]ARGS
      19 => :error,                # J->?: ERRCODE[0]ERR_TEXT
      20 => :status_res,           # C->J: HANDLE[0]KNOWN[0]RUNNING[0]NUM[0]DENOM
      21 => :submit_job_high,      # C->J: FUNC[0]UNIQ[0]ARGS
      22 => :set_client_id,        # W->J: [RANDOM_STRING_NO_WHITESPACE]
      23 => :can_do_timeout,       # W->J: FUNC[0]TIMEOUT
      24 => :all_yours,            # REQ    Worker
      25 => :work_exception,       # W->J: HANDLE[0]ARG
      26 => :option_req,           # C->J: TEXT
      27 => :option_res,           # J->C: TEXT
      28 => :work_data,            # REQ    Worker
      29 => :work_warning,         # W->J/C: HANDLE[0]MSG
      30 => :grab_job_uniq,        # REQ    Worker
      31 => :job_assign_uniq,      # RES    Worker
      32 => :submit_job_high_bg,   # C->J: FUNC[0]UNIQ[0]ARGS
      33 => :submit_job_low,       # C->J: FUNC[0]UNIQ[0]ARGS
      34 => :submit_job_low_bg,    # C->J: FUNC[0]UNIQ[0]ARGS
      35 => :submit_job_sched,     # REQ    Client
      36 => :submit_job_epoch      # C->J: FUNC[0]UNIQ[0]EPOCH[0]ARGS
    }
    COMMAND_INV = COMMANDS.invert

    def initialize
      %% write data;
      #%
    end

    def parse(data)
      eof = data.length
      packetnum = 0
      packets = []

      %% write init;
      %% write exec;

      packets
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
    end
  end

  def test
    Rgearmand.parse("\000REQ\000\000\000\020\0\0\0\005hello")
    Rgearmand.parse("\000REQ\000\000\000\020\0\0\0\005hello\000REQ\000\000\000\020\0\0\0\005hello")
  end
end