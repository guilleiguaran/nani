# coding: utf-8
require File.expand_path('../lib/nani/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "nani"
  spec.version       = Nani::VERSION
  spec.authors       = ["Guillermo Iguaran"]
  spec.email         = ["guilleiguaran@gmail.com"]
  spec.description   = %q{AMQP workers}
  spec.summary       = %q{Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "celluloid"
  spec.add_dependency "bunny", "~> 0.9.0.pre9"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "bundler", "~> 1.3"
end
