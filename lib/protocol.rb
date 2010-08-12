# line 1 "lib/protocol.rl"
=begin
# line 63 "lib/protocol.rl"

=end


module Rgearmand
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

  
# line 51 "lib/protocol.rb"
class << self
	attr_accessor :_gearman_actions
	private :_gearman_actions, :_gearman_actions=
end
self._gearman_actions = [
	0, 1, 0, 1, 4, 1, 7, 1, 
	8, 2, 1, 0, 2, 2, 0, 2, 
	3, 9, 2, 5, 4, 2, 6, 4, 
	4, 2, 0, 3, 9
]

class << self
	attr_accessor :_gearman_key_offsets
	private :_gearman_key_offsets, :_gearman_key_offsets=
end
self._gearman_key_offsets = [
	0, 0, 1, 2, 4, 5, 6, 7, 
	20, 22, 24, 26, 28, 29, 30, 31, 
	42, 43, 43
]

class << self
	attr_accessor :_gearman_trans_keys
	private :_gearman_trans_keys, :_gearman_trans_keys=
end
self._gearman_trans_keys = [
	82, 69, 81, 83, 0, 0, 0, 7, 
	9, 18, 1, 4, 12, 16, 21, 26, 
	28, 30, 32, 36, 0, 255, 0, 255, 
	0, 255, 0, 255, 0, 0, 0, 6, 
	8, 17, 25, 31, 10, 14, 19, 20, 
	27, 29, 0, 0
]

class << self
	attr_accessor :_gearman_single_lengths
	private :_gearman_single_lengths, :_gearman_single_lengths=
end
self._gearman_single_lengths = [
	0, 1, 1, 2, 1, 1, 1, 3, 
	0, 0, 0, 0, 1, 1, 1, 5, 
	1, 0, 0
]

class << self
	attr_accessor :_gearman_range_lengths
	private :_gearman_range_lengths, :_gearman_range_lengths=
end
self._gearman_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 5, 
	1, 1, 1, 1, 0, 0, 0, 3, 
	0, 0, 0
]

class << self
	attr_accessor :_gearman_index_offsets
	private :_gearman_index_offsets, :_gearman_index_offsets=
end
self._gearman_index_offsets = [
	0, 0, 2, 4, 7, 9, 11, 13, 
	22, 24, 26, 28, 30, 32, 34, 36, 
	45, 47, 48
]

class << self
	attr_accessor :_gearman_indicies
	private :_gearman_indicies, :_gearman_indicies=
end
self._gearman_indicies = [
	1, 0, 2, 0, 3, 4, 0, 6, 
	5, 7, 5, 8, 5, 9, 9, 9, 
	9, 9, 9, 9, 9, 5, 11, 10, 
	12, 10, 13, 10, 14, 10, 15, 5, 
	16, 5, 17, 5, 9, 9, 9, 9, 
	9, 9, 9, 9, 5, 18, 0, 20, 
	22, 0
]

class << self
	attr_accessor :_gearman_trans_targs
	private :_gearman_trans_targs, :_gearman_trans_targs=
end
self._gearman_trans_targs = [
	0, 2, 3, 4, 12, 0, 5, 6, 
	7, 8, 0, 9, 10, 11, 17, 13, 
	14, 15, 1, 16, 18, 16, 18
]

class << self
	attr_accessor :_gearman_trans_actions
	private :_gearman_trans_actions, :_gearman_trans_actions=
end
self._gearman_trans_actions = [
	3, 0, 0, 0, 0, 21, 1, 0, 
	0, 0, 18, 9, 0, 0, 0, 1, 
	0, 0, 0, 24, 12, 15, 0
]

class << self
	attr_accessor :_gearman_to_state_actions
	private :_gearman_to_state_actions, :_gearman_to_state_actions=
end
self._gearman_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	5, 0, 0
]

class << self
	attr_accessor :_gearman_from_state_actions
	private :_gearman_from_state_actions, :_gearman_from_state_actions=
end
self._gearman_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	7, 0, 0
]

class << self
	attr_accessor :_gearman_eof_actions
	private :_gearman_eof_actions, :_gearman_eof_actions=
end
self._gearman_eof_actions = [
	0, 3, 3, 3, 21, 21, 21, 21, 
	18, 18, 18, 18, 21, 21, 21, 21, 
	0, 0, 0
]

class << self
	attr_accessor :_gearman_eof_trans
	private :_gearman_eof_trans, :_gearman_eof_trans=
end
self._gearman_eof_trans = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 20, 22
]

class << self
	attr_accessor :gearman_start
end
self.gearman_start = 16;
class << self
	attr_accessor :gearman_first_final
end
self.gearman_first_final = 16;
class << self
	attr_accessor :gearman_error
end
self.gearman_error = 0;

class << self
	attr_accessor :gearman_en_main
end
self.gearman_en_main = 16;

# line 109 "lib/protocol.rl"
  #%%
  
  def parse(data)
    eof = data.length
    packet = {}

    
# line 216 "lib/protocol.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = gearman_start
	ts = nil
	te = nil
	act = 0
end
# line 116 "lib/protocol.rl"
    
# line 227 "lib/protocol.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_acts = _gearman_from_state_actions[cs]
	_nacts = _gearman_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _gearman_actions[_acts - 1]
			when 8 then
# line 1 "lib/protocol.rl"
		begin
ts = p
		end
# line 1 "lib/protocol.rl"
# line 262 "lib/protocol.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _gearman_key_offsets[cs]
	_trans = _gearman_index_offsets[cs]
	_klen = _gearman_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _gearman_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _gearman_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _gearman_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _gearman_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _gearman_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _gearman_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _gearman_trans_targs[_trans]
	if _gearman_trans_actions[_trans] != 0
		_acts = _gearman_trans_actions[_trans]
		_nacts = _gearman_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _gearman_actions[_acts - 1]
when 0 then
# line 7 "lib/protocol.rl"
		begin
 start = p 		end
# line 7 "lib/protocol.rl"
when 1 then
# line 9 "lib/protocol.rl"
		begin

    magic = data[start..p-1].unpack('N').first
    packet[:magic] = COMMANDS[magic]
  		end
# line 9 "lib/protocol.rl"
when 2 then
# line 14 "lib/protocol.rl"
		begin

    size = data[start..p-1].unpack('N').first
    packet[:size] = size
  		end
# line 14 "lib/protocol.rl"
when 3 then
# line 19 "lib/protocol.rl"
		begin

    data_end = start + packet[:size]
    packet[:data] = data[start..data_end]
    if packet[:size] != (packet[:data] && packet[:data].size)
      packet[:error] = "Size is invalid. Expected #{packet[:size]} bytes, but have #{packet[:data].size}."
    else
      packet[:arguments] = packet[:data].split("\0")
    end
  		end
# line 19 "lib/protocol.rl"
when 4 then
# line 29 "lib/protocol.rl"
		begin

    packet[:packet_valid] = false
  		end
# line 29 "lib/protocol.rl"
when 5 then
# line 33 "lib/protocol.rl"
		begin

    if p == 8
      packet[:error] = "Size header not found."
    else
      packet[:error] = "Size invalid: #{data[start..p-1].inspect}"
    end
  		end
# line 33 "lib/protocol.rl"
when 6 then
# line 41 "lib/protocol.rl"
		begin

    packet[:error] = "Magic header invalid: #{data[start..p-1].inspect}."
  		end
# line 41 "lib/protocol.rl"
when 9 then
# line 60 "lib/protocol.rl"
		begin
te = p
p = p - 1;		end
# line 60 "lib/protocol.rl"
# line 394 "lib/protocol.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _gearman_to_state_actions[cs]
	_nacts = _gearman_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _gearman_actions[_acts - 1]
when 7 then
# line 1 "lib/protocol.rl"
		begin
ts = nil;		end
# line 1 "lib/protocol.rl"
# line 415 "lib/protocol.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _gearman_eof_trans[cs] > 0
		_trans = _gearman_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
	__acts = _gearman_eof_actions[cs]
	__nacts =  _gearman_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _gearman_actions[__acts - 1]
when 4 then
# line 29 "lib/protocol.rl"
		begin

    packet[:packet_valid] = false
  		end
# line 29 "lib/protocol.rl"
when 5 then
# line 33 "lib/protocol.rl"
		begin

    if p == 8
      packet[:error] = "Size header not found."
    else
      packet[:error] = "Size invalid: #{data[start..p-1].inspect}"
    end
  		end
# line 33 "lib/protocol.rl"
when 6 then
# line 41 "lib/protocol.rl"
		begin

    packet[:error] = "Magic header invalid: #{data[start..p-1].inspect}."
  		end
# line 41 "lib/protocol.rl"
# line 470 "lib/protocol.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end
# line 117 "lib/protocol.rl"

    packet
  end
  module_function :parse
  
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

def test
  Rgearmand.parse("\000REQ\000\000\000\020\0\0\0\004hello")
end