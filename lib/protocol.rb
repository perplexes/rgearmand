
# line 1 "protocol.rl"
=begin

# line 107 "protocol.rl"

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

  
# line 53 "protocol.rb"
class << self
	attr_accessor :_gearman_actions
	private :_gearman_actions, :_gearman_actions=
end
self._gearman_actions = [
	0, 1, 0, 1, 1, 1, 6, 1, 
	7, 1, 8, 2, 4, 2, 2, 5, 
	3, 2, 6, 0, 3, 1, 6, 0, 
	3, 5, 3, 6, 3, 6, 1, 0, 
	3, 6, 5, 3, 4, 4, 2, 6, 
	0, 4, 5, 3, 6, 0, 4, 6, 
	4, 2, 0, 4, 6, 5, 3, 0, 
	5, 1, 5, 3, 6, 0, 5, 1, 
	6, 5, 3, 0, 5, 5, 3, 6, 
	1, 0, 5, 6, 1, 5, 3, 0
]

class << self
	attr_accessor :_gearman_key_offsets
	private :_gearman_key_offsets, :_gearman_key_offsets=
end
self._gearman_key_offsets = [
	0, 0, 1, 2, 3, 5, 6, 7, 
	8, 21, 23, 25, 27, 29, 30, 31, 
	32, 33, 34, 45, 47, 49, 51, 53, 
	54, 55, 56, 57, 59, 61, 64, 65, 
	67, 69, 84, 87, 91, 95, 99, 101, 
	102, 104, 107, 111, 114, 115, 117, 119, 
	132, 135, 139, 143, 147, 149, 150, 152, 
	155, 159, 162, 165, 169, 174, 175, 176, 
	179, 182, 186, 191, 192, 193, 196, 198, 
	200, 203, 204, 205, 206, 207, 209, 211, 
	214, 215, 217, 219, 234, 237, 241, 245, 
	249, 251, 253, 255, 258, 259, 260, 262, 
	265, 269, 272, 275, 279, 284, 285, 287, 
	288, 290, 293, 294, 296, 298, 311, 314, 
	318, 322, 326, 328, 329, 331, 334, 338, 
	341, 344, 348, 353, 354, 355, 358, 360, 
	362, 365, 366
]

class << self
	attr_accessor :_gearman_trans_keys
	private :_gearman_trans_keys, :_gearman_trans_keys=
end
self._gearman_trans_keys = [
	0, 82, 69, 81, 83, 0, 0, 0, 
	7, 9, 18, 1, 4, 12, 16, 21, 
	26, 28, 30, 32, 36, 0, 255, 0, 
	255, 0, 255, 0, 255, 0, 0, 0, 
	0, 0, 6, 8, 17, 25, 31, 10, 
	14, 19, 20, 27, 29, 0, 255, 0, 
	255, 0, 255, 0, 255, 0, 0, 0, 
	0, 0, 82, 0, 69, 0, 81, 83, 
	0, 0, 82, 0, 82, 0, 7, 9, 
	18, 82, 1, 4, 12, 16, 21, 26, 
	28, 30, 32, 36, 0, 1, 255, 0, 
	82, 1, 255, 0, 82, 1, 255, 0, 
	82, 1, 255, 0, 82, 0, 0, 69, 
	0, 1, 255, 0, 69, 1, 255, 0, 
	81, 83, 0, 0, 82, 0, 82, 0, 
	6, 8, 17, 25, 31, 82, 10, 14, 
	19, 20, 27, 29, 0, 1, 255, 0, 
	82, 1, 255, 0, 82, 1, 255, 0, 
	82, 1, 255, 0, 82, 0, 0, 69, 
	0, 1, 255, 0, 69, 1, 255, 0, 
	81, 83, 0, 1, 255, 0, 69, 1, 
	255, 0, 81, 83, 1, 255, 0, 0, 
	0, 1, 255, 0, 1, 255, 0, 69, 
	1, 255, 0, 81, 83, 1, 255, 0, 
	0, 0, 1, 255, 0, 82, 0, 69, 
	0, 81, 83, 0, 0, 0, 0, 0, 
	82, 0, 69, 0, 81, 83, 0, 0, 
	82, 0, 82, 0, 7, 9, 18, 82, 
	1, 4, 12, 16, 21, 26, 28, 30, 
	32, 36, 0, 1, 255, 0, 82, 1, 
	255, 0, 82, 1, 255, 0, 82, 1, 
	255, 0, 82, 0, 82, 0, 69, 0, 
	81, 83, 0, 0, 0, 69, 0, 1, 
	255, 0, 69, 1, 255, 0, 81, 83, 
	0, 1, 255, 0, 69, 1, 255, 0, 
	81, 83, 1, 255, 0, 0, 82, 0, 
	0, 82, 0, 1, 255, 0, 0, 82, 
	0, 82, 0, 6, 8, 17, 25, 31, 
	82, 10, 14, 19, 20, 27, 29, 0, 
	1, 255, 0, 82, 1, 255, 0, 82, 
	1, 255, 0, 82, 1, 255, 0, 82, 
	0, 0, 69, 0, 1, 255, 0, 69, 
	1, 255, 0, 81, 83, 0, 1, 255, 
	0, 69, 1, 255, 0, 81, 83, 1, 
	255, 0, 0, 0, 1, 255, 0, 82, 
	0, 69, 0, 81, 83, 0, 0, 0
]

class << self
	attr_accessor :_gearman_single_lengths
	private :_gearman_single_lengths, :_gearman_single_lengths=
end
self._gearman_single_lengths = [
	0, 1, 1, 1, 2, 1, 1, 1, 
	3, 0, 0, 0, 0, 1, 1, 1, 
	1, 1, 5, 0, 0, 0, 0, 1, 
	1, 1, 1, 2, 2, 3, 1, 2, 
	2, 5, 1, 2, 2, 2, 2, 1, 
	2, 1, 2, 3, 1, 2, 2, 7, 
	1, 2, 2, 2, 2, 1, 2, 1, 
	2, 3, 1, 2, 3, 1, 1, 1, 
	1, 2, 3, 1, 1, 1, 2, 2, 
	3, 1, 1, 1, 1, 2, 2, 3, 
	1, 2, 2, 5, 1, 2, 2, 2, 
	2, 2, 2, 3, 1, 1, 2, 1, 
	2, 3, 1, 2, 3, 1, 2, 1, 
	2, 1, 1, 2, 2, 7, 1, 2, 
	2, 2, 2, 1, 2, 1, 2, 3, 
	1, 2, 3, 1, 1, 1, 2, 2, 
	3, 1, 1
]

class << self
	attr_accessor :_gearman_range_lengths
	private :_gearman_range_lengths, :_gearman_range_lengths=
end
self._gearman_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	5, 1, 1, 1, 1, 0, 0, 0, 
	0, 0, 3, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 5, 1, 1, 1, 1, 0, 0, 
	0, 1, 1, 0, 0, 0, 0, 3, 
	1, 1, 1, 1, 0, 0, 0, 1, 
	1, 0, 1, 1, 1, 0, 0, 1, 
	1, 1, 1, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 5, 1, 1, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 0, 1, 1, 1, 0, 0, 0, 
	0, 1, 0, 0, 0, 3, 1, 1, 
	1, 1, 0, 0, 0, 1, 1, 0, 
	1, 1, 1, 0, 0, 1, 0, 0, 
	0, 0, 0
]

class << self
	attr_accessor :_gearman_index_offsets
	private :_gearman_index_offsets, :_gearman_index_offsets=
end
self._gearman_index_offsets = [
	0, 0, 2, 4, 6, 9, 11, 13, 
	15, 24, 26, 28, 30, 32, 34, 36, 
	38, 40, 42, 51, 53, 55, 57, 59, 
	61, 63, 65, 67, 70, 73, 77, 79, 
	82, 85, 96, 99, 103, 107, 111, 114, 
	116, 119, 122, 126, 130, 132, 135, 138, 
	149, 152, 156, 160, 164, 167, 169, 172, 
	175, 179, 183, 186, 190, 195, 197, 199, 
	202, 205, 209, 214, 216, 218, 221, 224, 
	227, 231, 233, 235, 237, 239, 242, 245, 
	249, 251, 254, 257, 268, 271, 275, 279, 
	283, 286, 289, 292, 296, 298, 300, 303, 
	306, 310, 314, 317, 321, 326, 328, 331, 
	333, 336, 339, 341, 344, 347, 358, 361, 
	365, 369, 373, 376, 378, 381, 384, 388, 
	392, 395, 399, 404, 406, 408, 411, 414, 
	417, 421, 423
]

class << self
	attr_accessor :_gearman_trans_targs
	private :_gearman_trans_targs, :_gearman_trans_targs=
end
self._gearman_trans_targs = [
	2, 0, 3, 0, 4, 0, 5, 15, 
	0, 6, 0, 7, 0, 8, 0, 9, 
	9, 9, 9, 9, 9, 9, 9, 0, 
	10, 0, 11, 0, 12, 0, 25, 0, 
	73, 26, 74, 26, 16, 0, 17, 0, 
	18, 0, 19, 19, 19, 19, 19, 19, 
	19, 19, 0, 20, 0, 21, 0, 22, 
	0, 75, 0, 129, 76, 130, 76, 70, 
	26, 27, 26, 27, 28, 26, 27, 29, 
	26, 27, 30, 44, 26, 31, 26, 32, 
	28, 26, 33, 28, 26, 27, 34, 34, 
	34, 28, 34, 34, 34, 34, 34, 26, 
	35, 69, 26, 36, 65, 64, 26, 37, 
	42, 41, 26, 38, 40, 39, 26, 27, 
	28, 26, 27, 26, 27, 29, 26, 38, 
	39, 26, 38, 43, 39, 26, 27, 30, 
	44, 26, 45, 26, 46, 28, 26, 47, 
	28, 26, 27, 48, 48, 48, 48, 48, 
	28, 48, 48, 48, 26, 49, 63, 26, 
	50, 59, 58, 26, 51, 56, 55, 26, 
	52, 54, 53, 26, 27, 28, 26, 27, 
	26, 27, 29, 26, 52, 53, 26, 52, 
	57, 53, 26, 27, 30, 44, 26, 51, 
	55, 26, 51, 60, 55, 26, 52, 61, 
	62, 53, 26, 31, 26, 45, 26, 50, 
	58, 26, 37, 41, 26, 37, 66, 41, 
	26, 38, 67, 68, 39, 26, 31, 26, 
	45, 26, 36, 64, 26, 27, 71, 26, 
	27, 72, 26, 27, 13, 14, 26, 32, 
	26, 46, 26, 126, 76, 77, 76, 77, 
	78, 76, 77, 79, 76, 77, 80, 106, 
	76, 81, 76, 82, 78, 76, 83, 78, 
	76, 77, 84, 84, 84, 78, 84, 84, 
	84, 84, 84, 76, 85, 105, 76, 86, 
	99, 98, 76, 87, 96, 95, 76, 88, 
	94, 93, 76, 89, 28, 26, 27, 90, 
	26, 27, 91, 26, 27, 30, 92, 26, 
	45, 26, 89, 26, 89, 29, 26, 88, 
	93, 76, 88, 97, 93, 76, 89, 30, 
	44, 26, 87, 95, 76, 87, 100, 95, 
	76, 88, 101, 103, 93, 76, 102, 26, 
	32, 90, 26, 104, 26, 46, 90, 26, 
	86, 98, 76, 107, 76, 108, 78, 76, 
	109, 78, 76, 77, 110, 110, 110, 110, 
	110, 78, 110, 110, 110, 76, 111, 125, 
	76, 112, 121, 120, 76, 113, 118, 117, 
	76, 114, 116, 115, 76, 77, 78, 76, 
	77, 76, 77, 79, 76, 114, 115, 76, 
	114, 119, 115, 76, 77, 80, 106, 76, 
	113, 117, 76, 113, 122, 117, 76, 114, 
	123, 124, 115, 76, 81, 76, 107, 76, 
	112, 120, 76, 77, 127, 76, 77, 128, 
	76, 77, 23, 24, 76, 82, 76, 108, 
	76, 0
]

class << self
	attr_accessor :_gearman_trans_actions
	private :_gearman_trans_actions, :_gearman_trans_actions=
end
self._gearman_trans_actions = [
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 3, 9, 0, 9, 0, 9, 0, 
	0, 0, 0, 0, 0, 0, 0, 9, 
	11, 7, 0, 7, 0, 7, 0, 7, 
	3, 0, 3, 0, 3, 9, 0, 9, 
	0, 9, 0, 0, 0, 0, 0, 0, 
	0, 0, 9, 11, 7, 0, 7, 0, 
	7, 0, 7, 3, 0, 3, 0, 41, 
	14, 17, 0, 17, 0, 0, 17, 0, 
	0, 17, 0, 0, 0, 20, 0, 17, 
	0, 0, 17, 0, 0, 17, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	36, 11, 0, 17, 0, 0, 0, 17, 
	0, 0, 0, 17, 0, 0, 0, 41, 
	14, 14, 41, 14, 41, 14, 14, 17, 
	0, 0, 17, 0, 0, 0, 41, 14, 
	14, 14, 28, 0, 17, 0, 0, 17, 
	0, 0, 17, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 46, 11, 0, 
	17, 0, 0, 0, 17, 0, 0, 0, 
	17, 0, 0, 0, 51, 14, 14, 51, 
	14, 51, 14, 14, 17, 0, 0, 17, 
	0, 0, 0, 51, 14, 14, 14, 17, 
	0, 0, 17, 0, 0, 0, 17, 0, 
	0, 0, 0, 62, 14, 74, 14, 17, 
	0, 0, 17, 0, 0, 17, 0, 0, 
	0, 17, 0, 0, 0, 0, 56, 14, 
	68, 14, 17, 0, 0, 17, 0, 0, 
	17, 0, 0, 17, 0, 0, 0, 17, 
	0, 17, 0, 41, 14, 17, 0, 17, 
	0, 0, 17, 0, 0, 17, 0, 0, 
	0, 20, 0, 17, 0, 0, 17, 0, 
	0, 17, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 36, 11, 0, 17, 
	0, 0, 0, 17, 0, 0, 0, 17, 
	0, 0, 0, 41, 14, 14, 17, 0, 
	0, 17, 0, 0, 17, 0, 0, 0, 
	20, 0, 41, 14, 41, 14, 14, 17, 
	0, 0, 17, 0, 0, 0, 41, 14, 
	14, 14, 17, 0, 0, 17, 0, 0, 
	0, 17, 0, 0, 0, 0, 56, 14, 
	17, 0, 0, 68, 14, 17, 0, 0, 
	17, 0, 0, 20, 0, 17, 0, 0, 
	17, 0, 0, 17, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 36, 11, 
	0, 17, 0, 0, 0, 17, 0, 0, 
	0, 17, 0, 0, 0, 41, 14, 14, 
	41, 14, 41, 14, 14, 17, 0, 0, 
	17, 0, 0, 0, 41, 14, 14, 14, 
	17, 0, 0, 17, 0, 0, 0, 17, 
	0, 0, 0, 0, 56, 14, 56, 14, 
	17, 0, 0, 17, 0, 0, 17, 0, 
	0, 17, 0, 0, 0, 17, 0, 17, 
	0, 0
]

class << self
	attr_accessor :_gearman_eof_actions
	private :_gearman_eof_actions, :_gearman_eof_actions=
end
self._gearman_eof_actions = [
	0, 0, 0, 0, 0, 9, 9, 9, 
	9, 7, 7, 7, 7, 9, 9, 9, 
	9, 9, 9, 7, 7, 7, 7, 9, 
	9, 24, 5, 5, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 24, 24, 
	24, 5, 5, 24, 5, 5, 5, 5, 
	5, 5, 5, 5, 32, 32, 32, 5, 
	5, 32, 5, 5, 5, 32, 32, 5, 
	5, 5, 5, 24, 24, 5, 5, 5, 
	5, 5, 5, 24, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	24, 5, 5, 5, 5, 24, 24, 5, 
	5, 24, 5, 5, 5, 24, 5, 24, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	5, 5, 24, 24, 24, 5, 5, 24, 
	5, 5, 5, 24, 24, 5, 5, 5, 
	5, 5, 5
]

class << self
	attr_accessor :gearman_start
end
self.gearman_start = 1;
class << self
	attr_accessor :gearman_first_final
end
self.gearman_first_final = 25;
class << self
	attr_accessor :gearman_error
end
self.gearman_error = 0;

class << self
	attr_accessor :gearman_en_main
end
self.gearman_en_main = 1;


# line 153 "protocol.rl"
  #%%
  
  def parse(data)
    eof = data.length
    packetnum = 0
    #packet = {}
    packets = []
    
# line 394 "protocol.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = gearman_start
end

# line 161 "protocol.rl"
    
# line 403 "protocol.rb"
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
# line 7 "protocol.rl"
		begin
 
    puts "headmark: #{p}"
    puts "D: #{data[p-1]}"
    puts data
    start = p 
  		end
when 1 then
# line 14 "protocol.rl"
		begin
 
    puts "magicmark: #{p}"
    puts "D: #{data[p]} #{data[p+1]} #{data[p+2]} #{data[p+3]}"
    puts data
    start = p 
  		end
when 2 then
# line 21 "protocol.rl"
		begin
 
    puts "sizemark: #{p}"
    start = p 
  		end
when 3 then
# line 26 "protocol.rl"
		begin
 
    puts "datamark: #{p}"
    start = p 
  		end
when 4 then
# line 31 "protocol.rl"
		begin

    puts "Packet #: #{packetnum}"
    packets << {}
    magic = data[start..p-1].unpack('N').first
    packets[packetnum][:magic] = COMMANDS[magic]
  		end
when 5 then
# line 38 "protocol.rl"
		begin

    puts "Size: #{p}"
    size = data[start..p-1].unpack('N').first
    packets[packetnum][:size] = size
  		end
when 6 then
# line 44 "protocol.rl"
		begin

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
  		end
when 7 then
# line 71 "protocol.rl"
		begin

    if p == 8
      packets[packetnum][:error] = "Size header not found."
    else
      packets[packetnum][:error] = "Size invalid: #{data[start..p-1].inspect}"
    end
  		end
when 8 then
# line 79 "protocol.rl"
		begin

    puts "NARFLE"
    packets[packetnum][:error] = "Magic header invalid: #{data[start..p-1].inspect}."
  		end
# line 573 "protocol.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
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
	__acts = _gearman_eof_actions[cs]
	__nacts =  _gearman_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _gearman_actions[__acts - 1]
when 3 then
# line 26 "protocol.rl"
		begin
 
    puts "datamark: #{p}"
    start = p 
  		end
when 5 then
# line 38 "protocol.rl"
		begin

    puts "Size: #{p}"
    size = data[start..p-1].unpack('N').first
    packets[packetnum][:size] = size
  		end
when 6 then
# line 44 "protocol.rl"
		begin

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
  		end
when 7 then
# line 71 "protocol.rl"
		begin

    if p == 8
      packets[packetnum][:error] = "Size header not found."
    else
      packets[packetnum][:error] = "Size invalid: #{data[start..p-1].inspect}"
    end
  		end
when 8 then
# line 79 "protocol.rl"
		begin

    puts "NARFLE"
    packets[packetnum][:error] = "Magic header invalid: #{data[start..p-1].inspect}."
  		end
# line 657 "protocol.rb"
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

# line 162 "protocol.rl"

    packets
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
  Rgearmand.parse("\000REQ\000\000\000\020\0\0\0\005hello")
  Rgearmand.parse("\000REQ\000\000\000\020\0\0\0\005hello\000REQ\000\000\000\020\0\0\0\005hello")
end