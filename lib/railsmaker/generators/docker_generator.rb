require_relative "server_command_generator"

module RailsMaker
  module Generators
    class DockerGenerator < ServerCommandGenerator
      source_root File.expand_path("templates/docker", __dir__)
      
      def install_docker
        return unless ssh_available?

        template "install_commands.sh.erb", "/tmp/docker_install.sh"
        execute_remote_commands([
          "chmod +x /tmp/docker_install.sh",
          "/tmp/docker_install.sh",
          "rm /tmp/docker_install.sh"
        ],
          title: "Installing Docker on remote Ubuntu server #{ssh_user}@#{ssh_host}",
          force: options[:force]
        )
      end
    end
  end
end 