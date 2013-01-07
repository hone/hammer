# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vise"
  s.version = "0.0.1.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Terence Lee"]
  s.date = "2013-01-06"
  s.description = "Library to assist with building binaries using Heroku's anvil"
  s.email = ["hone02@gmail.com"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Library to assist with building binaries using Heroku's anvil"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
