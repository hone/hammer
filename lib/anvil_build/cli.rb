require "anvil_build/shell_tools"
require 'thor'
require 'fileutils'
require 'tmpdir'
require 'uri'

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
binary.compile do |workspace_dir, output_dir, version|
  Dir.chdir(workspace_dir) do
    system("env HOME=\#{workspace_dir} /tmp/build \#{workspace_dir} \#{output_dir}")
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
    method_option :version, :type => :string,
      :desc => "the version of the project"
    method_option :local, :type => :boolean, :default => false,
      :desc => "flag to do a local build"
    method_option :debug, :type => :boolean, :default => false,
      :desc => "set build to be debugged"
    method_option :build, :type => :string, :default => ".",
      :desc => "path to the build scripts"
    method_option :env, :type => :hash,
      :desc => "build environment to pass to the build script"
    def build
      env = {:VERSION => options[:version], :DEBUG => options[:debug]}
      cmd = ""
      if env.values.any?
        cmd << "env "
        env.each do |key, value|
          cmd << "#{key}=#{value}" if value
        end
        cmd << " "
      end

      if options[:local]
        tmpdir    = Dir.mktmpdir
        build_dir = "#{tmpdir}/build"
        cache_dir = "#{tmpdir}/cache"
        FileUtils.mkdir_p build_dir
        FileUtils.mkdir_p cache_dir

        puts "Building..."
        cmd << "bin/compile #{build_dir} #{cache_dir}"
        pipe cmd
        puts "Done."

        require 'digest/sha1'
        package_name = Digest::SHA1.hexdigest(rand.to_s)
        Dir.chdir(build_dir) do
          puts "Packaging..."
          pipe "tar cvf ../#{package_name}.tgz ."
        end
        FileUtils.mv("#{tmpdir}/#{package_name}.tgz", ".")
        puts "tarball here: ./#{package_name}.tgz"
      else
        require 'anvil/engine'
        slug_url = nil
        pwd      = Dir.pwd

        Dir.mktmpdir do |dir|
          system("cp -rf #{options[:build]}/* #{dir}")

          Dir.chdir(dir) do
            FileUtils.mkdir_p("bin")
            Dir.chdir("bin") do
              write_bin_file('detect', read_bin_file("detect"))
              write_bin_file('compile', read_bin_file("compile"))
              write_bin_file('release', read_bin_file("release"))
            end
            if options[:env]
              File.open('env', 'wb') do |file|
                options[:env].each {|k, v| file.puts "#{k}=#{v}" }
              end
            end
            File.open('Gemfile', 'wb') do |file|
              file.puts <<GEMFILE
source "https://rubygems.org"

gem 'anvil_build', "~> #{AnvilBuild::VERSION}", :github => 'hone/anvil_build'
GEMFILE
            end
            system("bundle install --standalone")

            slug_url = Anvil::Engine.build(".", :buildpack => ".")
          end
        end

        Dir.mktmpdir do |dir|
          filename = URI.parse(slug_url).path.sub("/slugs/", "")

          Dir.chdir(dir) do
            system("curl -O #{slug_url}")
            system("tar zxf #{filename}")
            system("rm -rf #{filename} .profile.d .bundle Procfile .gitignore")
            system("tar czf #{filename} *")
            system("mv #{filename} #{pwd}")
          end
        end
      end
    ensure
      if options[:local]
        if env[:DEBUG]
          puts "Build artifacts here: #{tmpdir}"
        else
          FileUtils.rm_rf(tmpdir)
        end
      end
    end

    private
    def write_bin_file(name, contents)
      File.open(name, 'wb') do |file|
        file.chmod(0755)
        file.puts contents
      end
    end

    def read_bin_file(name)
      File.read(File.join(File.dirname(__FILE__), "bin/#{name}"))
    end
  end
end
