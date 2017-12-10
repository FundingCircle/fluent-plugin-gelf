# frozen_string_literal: true

require "helper"
require "fluent/plugin/formatter_gelf.rb"

class GelfFormatterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @d = create_driver("")
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Formatter.new(Fluent::Plugin::GelfFormatter).configure(conf)
  end

  fixtures.each_pair do |file, v|
    test "format #{file}" do
      time = v["event"]["time"]
      parsed_time = time.is_a?(Integer) ? time : event_time(time)
      formatted = @d.instance.format(v["event"]["tag"], parsed_time, v["event"]["record"])
      assert_equal v["expected"].to_json, formatted
    end
  end
end
