# frozen_string_literal: true

require 'English'
module RailsMaker
  module Generators
    class ServerCommandGenerator < BaseGenerator
      argument :ssh_host
      argument :ssh_user
      class_option :key_path, type: :string, default: '~/.ssh/id_rsa',
                              desc: 'Path to SSH private key'
      class_option :force, type: :boolean, default: false,
                           desc: 'Force installation even if already installed'

      protected

      def execute_remote_commands(commands, options = {})
        check_prerequisites

        if installation_exists?(options[:check_path]) && !options[:force]
          say_status 'skip', "Installation already exists at #{options[:check_path]}", :yellow
          say 'Use --force to reinstall', :yellow
          return
        end

        title = options[:title] || 'Executing remote commands'
        say_status 'start', title, :blue

        wrapped_commands = commands.map do |cmd|
          <<~SHELL
            echo "→ Executing: #{cmd}"
            if ! #{cmd}; then
              echo "✗ Command failed: #{cmd}"
              exit 1
            fi
          SHELL
        end

        ssh_command = wrapped_commands.join("\n")

        full_command = [
          'ssh',
          '-i', options[:key_path],
          '-o', 'StrictHostKeyChecking=accept-new', # Auto-accept new host keys
          '-o', 'ConnectTimeout=10',                # Fail fast on connection issues
          '-t',                                     # Force pseudo-terminal for better output
          "#{ssh_user}@#{ssh_host}",
          "'#{ssh_command}'"
        ].join(' ')

        system(full_command)
        exit_status = $CHILD_STATUS.exitstatus

        if exit_status.zero?
          say_status 'success', 'All commands completed successfully', :green
        else
          say_status 'error', "Command failed with exit status #{exit_status}", :red
          case exit_status
          when 255
            say '  → Could not connect to the server. Please check:', :red
            say '    • SSH host and user are correct'
            say "    • SSH key path exists: #{options[:key_path]}"
            say '    • Server is reachable and SSH port (22) is open'
          when 126, 127
            say '  → Command not found or not executable', :red
            say '    • Ensure all required software is installed on the remote server'
          end
          exit exit_status
        end
      end

      private

      def installation_exists?(check_path)
        return false unless check_path

        check_command = "ssh -i #{options[:key_path]} #{ssh_user}@#{ssh_host} '[ -d #{check_path} ]'"
        system(check_command, out: File::NULL, err: File::NULL)
      end

      def check_prerequisites
        unless File.exist?(File.expand_path(options[:key_path]))
          say_status 'error', "SSH key not found: #{options[:key_path]}", :red
          exit 1
        end

        say_status 'check', 'Testing SSH connection...', :blue
        test_command = "ssh -i #{options[:key_path]} -o ConnectTimeout=5 #{ssh_user}@#{ssh_host} 'echo OK'"
        unless system(test_command, out: File::NULL, err: File::NULL)
          say_status 'error', "Could not connect to #{ssh_user}@#{ssh_host}", :red
          say 'Please ensure:'
          say '  • The server is reachable'
          say '  • Your SSH key is valid'
          say '  • The user has access to the server'
          exit 1
        end
        say_status 'success', 'SSH connection successful', :green
      end
    end
  end
end
