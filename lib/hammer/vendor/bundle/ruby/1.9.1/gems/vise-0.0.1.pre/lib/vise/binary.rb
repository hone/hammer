require "vise/shell_tools"
require "tmpdir"

module Vise
  # class assists in building binaries using anvil on Heroku.
  class Binary
    include ShellTools

    # @param [String] path to the build dir
    # @param [String] path to the cache dir
    # ensures the following:
    # * move the building scripts into /tmp
    # * the script /tmp/build` is executable
    # * build dir is clean
    def initialize(build_dir, cache_dir)
      @build_dir = build_dir
      @cache_dir = cache_dir
      pipe "mv #{@build_dir}/* /tmp"
      pipe "chmod u+x /tmp/build"
      pipe "rm -rf #{@build_dir}/*"
    end

    # this is the main compile method.
    # pass a block to compile of what you want to run.
    # the block gets the source dir to work in, and a
    # build dir which is the dir that gets packaged.
    def compile
      tmpdir  = Dir.mktmpdir
      Dir.chdir(tmpdir) do |source_dir, build_dir|
        yield source_dir, @build_dir
      end

      puts "Packaging the following files/dirs:"
      pipe "ls #{@build_dir}"
    ensure
      if ENV['DEBUG']
        puts "Source dir: #{tmpdir}"
      else
        FileUtils.rm_rf(tmpdir)
      end
    end
  end
end
