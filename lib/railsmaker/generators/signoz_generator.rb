require_relative "server_command_generator"

module RailsMaker
  module Generators
    class SignozGenerator < ServerCommandGenerator
      def install_signoz
        commands = [
          "git clone -b main https://github.com/SigNoz/signoz.git",
          "cd signoz/deploy/ && ./install.sh",
          "docker compose -f ./docker/clickhouse-setup/docker-compose.yaml down"
        ]

        execute_remote_commands(commands, 
          title: "Installing SigNoz on remote server #{ssh_user}@#{ssh_host}",
          check_path: "~/signoz",
          force: options[:force]
        )
      end
    end
  end
end