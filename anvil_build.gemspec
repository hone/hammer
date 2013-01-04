# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anvil_build/version'

Gem::Specification.new do |gem|
  gem.name          = "anvil_build"
  gem.version       = AnvilBuild::VERSION
  gem.authors       = ["Terence Lee"]
  gem.email         = ["hone02@gmail.com"]
  gem.description   = %q{Library to assist with building binaries using Heroku's anvil}
  gem.summary       = %q{Library to assist with building binaries using Heroku's anvil}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "thor", "~> 0.15.0"
  gem.add_development_dependency "anvil-cli", "~> 0.14.0"
end
