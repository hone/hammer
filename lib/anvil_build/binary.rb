require "anvil_build/shell_tools"
require "tmpdir"

module AnvilBuild
  # class assists in building binaries using anvil on Heroku.
  class Binary
    include ShellTools

    # @param [String] path to the build dir
    # @param [String] path to the cache dir
    # ensures the build dir is clean
    def initialize(build_dir, cache_dir)
      @build_dir = build_dir
      @cache_dir = cache_dir
      pipe "rm -rf #{@build_dir}/*"
    end

    # this is the main compile method.
    # pass a block to compile of what you want to run.
    # the block gets the build dir, which is what you want
    # to either use as the --prefix for most configure blocks
    # or at least ensure the artifacts you want to be in the
    # final tarball is there.
    def compile
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do |dir|
          yield dir
        end
      end
    end
  end
end
