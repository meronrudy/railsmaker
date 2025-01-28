require_relative "server_command_generator"

module RailsMaker
  module Generators
    class DockerGenerator < ShellScriptGenerator
      def initialize(*args)
        super
        options[:script_name] = "docker"
        options[:title] = "Installing Docker on remote Ubuntu server #{ssh_user}@#{ssh_host}"
      end
    end
  end
end 