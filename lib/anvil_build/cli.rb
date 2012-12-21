require "anvil_build/shell_tools"
require 'thor'
require 'fileutils'
require 'tmpdir'

module AnvilBuild
  class CLI < Thor
    include ShellTools

    desc "new PROJECT_NAME", "generate a new binary project"
    def new(name)
      puts "Creating buildpack skeleton..."
      puts "#{name}/"
      FileUtils.mkdir(name)

      Dir.chdir(name) do
        puts "#{name}/Gemfile"
        File.open('Gemfile', 'wb') do |file|
          file.puts <<GEMFILE
source "https://rubygems.org"

gem 'anvil_build', "~> #{AnvilBuild::VERSION}", :github => 'hone/anvil_build'
GEMFILE
        end

        puts "#{name}/bin"
        FileUtils.mkdir("bin")
        Dir.chdir("bin") do
          puts "#{name}/bin/detect"
          File.open("detect", 'wb') do |file|
            file.chmod(0755)
            file.puts <<DETECT
#!/usr/bin/env bash

echo "#{name}"
DETECT
          end

          puts "#{name}/bin/release"
          File.open("release", 'wb') do |file|
            file.chmod(0755)
            file.puts <<RELEASE
#!/usr/bin/env bash

echo "--- {}"
RELEASE
          end

          puts "#{name}/bin/compile"
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

    desc "build", "builds the binary"
    #method_option :version, :type => :string
    #  :desc => "the version of the project"
    method_option :local, :type => :boolean, :default => false,
      :desc => "flag to do a local build"
    method_option :debug, :type => :boolean, :default => false,
      :desc => "set build to be debugged"
    def build
      cmd = ""
      cmd << "env DEBUG=1 " if options[:debug]

      if options[:local]
        tmpdir    = Dir.mktmpdir
        build_dir = "#{tmpdir}/build"
        cache_dir = "#{tmpdir}/cache"
        FileUtils.mkdir_p build_dir
        FileUtils.mkdir_p cache_dir
        puts "Creating tmpdir for build output: #{tmpdir}/build"

        puts "Building..."
        cmd << "bin/compile #{build_dir} #{cache_dir}"
        pipe cmd
        puts "Done."
        puts "Build artifacts here: #{tmpdir}"
      end
    end
  end
end
