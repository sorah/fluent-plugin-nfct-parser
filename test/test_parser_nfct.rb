require "fluent/test"
require "fluent/test/helpers"
require "fluent/test/driver/parser"
require "fluent/plugin/parser_nfct"

Test::Unit::TestCase.include(Fluent::Test::Helpers)

class NfctParserTest < ::Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def test_normal()
    text = '    [NEW] udp      17 30 src=127.0.0.1 dst=127.0.0.1 sport=32679 dport=32679 [UNREPLIED] src=127.0.0.1 dst=127.0.0.1 sport=32679 dport=32679'
    create_driver({}).instance.parse(text) do |_, r|
       assert_equal({"msg_type"=>"NEW", "protocol"=>"udp", "protonum"=>17, "timeout"=>30, "state"=>nil, "src"=>"127.0.0.1", "dst"=>"127.0.0.1", "sport"=>32679, "dport"=>32679, "unreplied"=>true}, r)
    end
  end

  def test_state()
    text = ' [UPDATE] tcp      6 30 FIN_WAIT src=192.0.2.211 dst=192.0.2.2 sport=50362 dport=10051 src=192.0.2.2 dst=192.0.2.211 sport=10051 dport=50362 [ASSURED]'
    create_driver({}).instance.parse(text) do |_, r|
      assert_equal({"msg_type"=>"UPDATE", "protocol"=>"tcp", "protonum"=>6, "timeout"=>30, "state"=>"FIN_WAIT", "src"=>"192.0.2.2", "dst"=>"192.0.2.211", "sport"=>10051, "dport"=>50362, "assured"=>true}, r)
    end
  end

  def test_extended()
    text = '[DESTROY] ipv4     2 tcp      6 src=192.0.2.211 dst=192.0.2.2 sport=50482 dport=10051 src=192.0.2.2 dst=192.0.2.211 sport=10051 dport=50482 [ASSURED] delta-time=7'
    create_driver({extended: true}).instance.parse(text) do |_, r|
      assert_equal({"msg_type"=>"DESTROY", "l3protocol"=>"ipv4", "l3protonum"=>2, "protocol"=>"tcp", "protonum"=>6, "timeout"=>nil, "state"=>nil, "src"=>"192.0.2.2", "dst"=>"192.0.2.211", "sport"=>10051, "dport"=>50482, "assured"=>true, "delta-time"=>7}, r)

    end
  end

  def test_ktimestamp()
    text = '[DESTROY] udp      17 src=192.0.2.211 dst=192.0.2.53 sport=22041 dport=53 src=192.0.2.53 dst=192.0.2.211 sport=53 dport=22041 delta-time=31 [start=Tue May 29 09:40:13 2018] [stop=Tue May 29 09:40:44 2018]'
    create_driver({ktimestamp: true}).instance.parse(text) do |_, r|
      assert_equal({"msg_type"=>"DESTROY", "protocol"=>"udp", "protonum"=>17, "timeout"=>nil, "state"=>nil, "src"=>"192.0.2.53", "dst"=>"192.0.2.211", "sport"=>53, "dport"=>22041, "delta-time"=>31, "start"=>1527554413, "stop"=>1527554444}, r)
    end
  end

  def create_driver(conf)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::NfctParser).configure(conf)
  end
end
