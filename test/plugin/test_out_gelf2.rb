# frozen_string_literal: true

require "helper"
require "fluent/plugin/out_gelf2.rb"
require "test/unit/rr"

class Gelf2OutputTest < Test::Unit::TestCase
  CONFIG = %(
    host localhost
  )

  MULTI_RECORD_WRITE = "{\"timestamp\":1512335408.558,\"_fluentd_tag\":\"test\",\
\"_foo\":\"bar\",\"short_message\":\"(no message)\"}\u0000{\"timestamp\":1512335409.123,\
\"_fluentd_tag\":\"test\",\"_bar\":\"baz\",\"short_message\":\"(no message)\"}\u0000"

  setup do
    Fluent::Test.setup
    @d = create_driver(CONFIG)
    @stubbed_tcp = Object.new
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::Gelf2Output).configure(conf)
  end

  test "test config" do
    assert_equal "localhost", @d.instance.host
    assert_equal 12_201, @d.instance.port
  end

  test "write of multiple records chunk" do
    mock(TCPSocket).new(@d.instance.host, @d.instance.port) { @stubbed_tcp }
    mock(@stubbed_tcp).write(MULTI_RECORD_WRITE)
    mock(@stubbed_tcp).close
    @d.run(default_tag: "test") do
      @d.feed(event_time("2017-12-03 21:10:08.558Z UTC"), "foo": "bar")
      @d.feed(event_time("2017-12-03 21:10:09.123Z UTC"), "bar": "baz")
    end
  end

  fixtures.each_pair do |file, v|
    test "format #{file}" do
      stub(TCPSocket).new { @stubbed_tcp }
      stub(@stubbed_tcp).write
      stub(@stubbed_tcp).close
      @d.run(default_tag: v["event"]["tag"]) do
        time = v["event"]["time"]
        parsed_timet = time.is_a?(Integer) ? time : event_time(time)
        @d.feed(parsed_timet, v["event"]["record"])
      end
      assert_equal [v["expected"].to_msgpack], @d.formatted
    end
  end
end
