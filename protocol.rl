require 'ruby-debug'
Debugger.start

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

=begin
%%{

  machine gearman;
  alphtype int;
  
  action mark { start = p }

  action magic {
    magic = data[start..p-1].unpack('N').first
    packet[:magic] = COMMANDS[magic]
  }
  
  action size {
    size = data[start..p-1].unpack('N').first
    packet[:size] = size
    data_start = p
  }
  
  action data {
    puts "data"
    packet[:data] = data[data_start..p-1]
  }
  
  action test_size { puts "match size"; true }
  
  size        = (0..255){4};
  size_cap    = size >mark %size;
  data        = any*;
  data_cap    = data >mark %data;
  req_head    = 0 'REQ';
  res_head    = 0 'RES';
  req_magic   = 0{3} (1|2|3|4|7|9|12|13|14|15|16|18|21|22|23|24|25|26|28|29|30|32|33|34|35|36);
  res_magic   = 0{3} (6|8|10|11|12|13|14|17|19|20|25|27|28|29|31);
  req_magic_cap = req_magic >mark %magic;
  res_magic_cap = res_magic >mark %magic;
  req_packet  = req_head req_magic_cap size_cap data_cap;
  res_packet  = res_head res_magic_cap size_cap data_cap;
  packet      = (req_packet | res_packet) %data;
  
  main := |*
    packet => {};
  *|;

}%%
=end

%% write data;
#%%

def run(data)
  eof = -1
  packet = {}
  
  %% write init;
  %% write exec;

  packet
end

def test
  run("\000REQ\000\000\000\020\000\000\000\005hello")
end