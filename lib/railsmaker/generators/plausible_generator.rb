require_relative "server_command_generator"

module RailsMaker
  module Generators
    class PlausibleGenerator < ServerCommandGenerator
      argument :analytics_host, desc: "Domain where Plausible will be hosted (e.g., plausible.example.com)"

      def install_plausible
        commands = [
          "git clone -b v2.1.4 --single-branch https://github.com/plausible/community-edition plausible-ce",
          "cd plausible-ce",
          "touch .env",
          <<~SHELL,
            echo "BASE_URL=https://#{analytics_host}" >> .env
            echo "SECRET_KEY_BASE=$(openssl rand -base64 48)" >> .env
            echo "HTTP_PORT=80" >> .env
            echo "HTTPS_PORT=443" >> .env
          SHELL
          <<~SHELL
            cat > compose.override.yml << 'EOF'
            services:
              plausible:
                ports:
                  - 80:80
                  - 443:443
            EOF
          SHELL
        ]

        execute_remote_commands(commands,
          title: "Installing Plausible Analytics on remote server #{ssh_user}@#{ssh_host}",
          check_path: "~/plausible-ce",
          force: options[:force]
        )
      end
    end
  end
end 