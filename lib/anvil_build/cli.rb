require "anvil_build/shell_tools"
require 'thor'
require 'fileutils'

module AnvilBuild
  class CLI < Thor
    include ShellTools

    desc "new", "generate a new binary project"
    def new(name)
      FileUtils.mkdir(name)

      Dir.chdir(name) do
        File.open('Gemfile', 'wb') do |file|
          file.puts <<GEMFILE
source "https://rubygems.org"

gem 'anvil_build', "~> #{AnvilBuild::VERSION}", :github => 'hone/anvil_build'
GEMFILE
        end
        FileUtils.mkdir("bin")
        Dir.chdir("bin") do
          File.open("detect", 'wb') do |file|
            file.chmod(0755)
            file.puts <<DETECT
#!/usr/bin/env bash

echo "#{name}"
DETECT
          end
          File.open("release", 'wb') do |file|
            file.chmod(0755)
            file.puts <<RELEASE
#!/usr/bin/env bash

echo "--- {}"
RELEASE
          end
          File.open("compile", 'wb') do |file|
            file.chmod(0755)
            file.puts <<COMPILE
#!/usr/bin/env ruby

require_relative '../vendor/bundle/bundler/setup'
require 'anvil_build'

include AnvilBuild::ShellTools

DEFAULT_VERSION = "0.1"
version = ENV['VERSION'] || DEFAULT_VERSION

binary = AnvilBuild::Binary.new(ARGV[0], ARGV[1])
binary.compile do |build_dir|
  full_name = "#{name}-\#{version}"
  # download source
  pipe "curl http://example.com/\#{full_name}.tar.gz -s -o - | tar vzxf -"

  Dir.chdir("\#{full_name}") do |dir|
    [
      "env CFLAGS=-fPIC ./configure --enable-static --disable-shared --prefix=\#{build_dir}",
      "make",
      "make install"
    ].each {|cmd| pipe(cmd) }
  end
end
COMPILE
          end
        end

        puts "running `bundle install --standalone`"
        pipe "env BUNDLE_GEMFILE=Gemfile bundle install --standalone"
      end
    end
  end
end
