# frozen_string_literal: true

require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"
require "rubocop/rake_task"

Rake::TestTask.new(:test) do |t|
  t.libs.push("lib", "test")
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
  t.warning = true
end

RuboCop::RakeTask.new(:rubocop)

task default: %i[rubocop test]
