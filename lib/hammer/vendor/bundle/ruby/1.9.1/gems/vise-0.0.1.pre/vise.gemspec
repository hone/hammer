# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vise/version'

Gem::Specification.new do |gem|
  gem.name          = "vise"
  gem.version       = Vise::VERSION
  gem.authors       = ["Terence Lee"]
  gem.email         = ["hone02@gmail.com"]
  gem.description   = %q{Library to assist with building binaries using Heroku's anvil}
  gem.summary       = %q{Library to assist with building binaries using Heroku's anvil}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
end
