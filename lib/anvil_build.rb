require "anvil_build/version"
require "tmpdir"

module AnvilBuild
  # class assists in building binaries using anvil on Heroku.
  class Binary
    # @param [String] path to the build dir
    # @param [String] path to the cache dir
    # ensures the build dir is clean
    def initialize(build_dir, cache_dir)
      @build_dir = build_dir
      @cache_dir = cache_dir
      pipe "rm -rf #{@buid_dir}/*"
    end

    # this is the main compile method.
    # pass a block to compile of what you want to run.
    # the block gets the build dir, which is what you want
    # to either use as the --prefix for most configure blocks
    # or at least ensure the artifacts you want to be in the
    # final tarball is there.
    def compile
      Dir.mktmpdir("libyaml-") do |tmpdir|
        Dir.chdir(tmpdir) do |dir|
          yield dir
        end
      end
    end
  end

  private
  # run a shell command and stream the output
  # @param [String] command to be run
  def pipe(command)
    output = ""
    IO.popen(command) do |io|
      until io.eof?
        buffer = io.gets
        output << buffer
        puts buffer
      end
    end

    output
  end

end
