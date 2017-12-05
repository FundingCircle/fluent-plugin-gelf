# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "test-unit"
require "fluent/test"
require "fluent/test/driver/output"
require "fluent/test/helpers"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

def fixtures
  path = File.expand_path("../fixtures", __FILE__)
  all_fixure_files = Dir["#{path}/*.json"]
  all_fixtures = {}
  all_fixure_files.each do |file|
    all_fixtures[File.basename(file)] = JSON.parse(File.read(file))
  end
  all_fixtures
end
