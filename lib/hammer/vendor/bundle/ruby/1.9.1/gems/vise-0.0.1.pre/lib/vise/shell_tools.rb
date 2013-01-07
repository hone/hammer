module Vise
  # convenience methods for interacting with the shell
  # in ruby that can be used in your build program
  module ShellTools
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
end
