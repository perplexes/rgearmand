require 'helper'

class TestGearmanServer < Test::Unit::TestCase
  context "Protocol" do
    setup do
      @server = GearmanServer.new
    end
  
    should "parse protocol packets" do
      @server.parse_packets("\000REQ\000\000\000\020\0\0\0\005hello") do |cmd, args|
        assert_equal :echo_req, cmd 
        assert_equal ['hello'], args
      end
      
      # Multiple
      packets = []
      @server.parse_packets("\000REQ\000\000\000\020\0\0\0\005hello\000REQ\000\000\000\020\0\0\0\005hello") do |cmd, args|
        packets << [cmd, args]
      end
      assert_equal packets, [[:echo_req, ['hello']], [:echo_req, ['hello']]]
    end
  end
end
