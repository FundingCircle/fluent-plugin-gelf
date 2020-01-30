# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-gelf"
  spec.version = "0.2.3"
  spec.authors = ["Funding Circle"]
  spec.email   = ["engineering@fundingcircle.com"]

  spec.summary       = "Graylog output plugin for Fluentd"
  spec.description   = "Convers fluentd log events into GELF format and sends it graylog"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "oj", "~> 3.3.10"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "test-unit-rr", "~> 1.0.5"
  spec.add_development_dependency "rubocop", "~> 0.50.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
