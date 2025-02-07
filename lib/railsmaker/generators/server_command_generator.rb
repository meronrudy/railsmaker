# frozen_string_literal: true

require 'English'
require 'fileutils'
require 'base64'

module RailsMaker
  module Generators
    class ServerCommandGenerator < BaseGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :ssh_host, type: :string, required: true, desc: 'SSH host'
      class_option :ssh_user, type: :string, required: true, desc: 'SSH user'
      class_option :key_path, type: :string, desc: 'Path to SSH private key (optional)'
      class_option :force, type: :boolean, default: false,
                           desc: 'Force installation even if already installed'

      def execute_script
        return unless ssh_available?

        say "⚠️  WARNING: This command will SSH into #{options[:ssh_user]}@#{options[:ssh_host]} and install software.",
            :yellow
        return unless yes?('Do you want to proceed? (y/N)')

        # Generate all file contents first
        remote_files_content = remote_files.map do |file|
          template file[:template], "/tmp/#{file[:filename]}"
          content = File.read("/tmp/#{file[:filename]}")
          FileUtils.rm("/tmp/#{file[:filename]}")
          [file[:filename], Base64.strict_encode64(content)]
        end.to_h

        file_commands = remote_files_content.map do |filename, content|
          [
            "echo '#{content}' | base64 -d > /tmp/#{filename}",
            filename == 'install_script.sh' ? 'chmod +x /tmp/install_script.sh' : nil
          ]
        end.flatten.compact

        execute_remote_commands(
          [*file_commands, *install_commands],
          title: title,
          check_path: check_path,
          force: options[:force]
        )
      end

      protected

      def script_name
        raise NotImplementedError, 'Subclasses must implement #script_name'
      end

      def check_path
        nil
      end

      def title
        "Executing #{script_name} script"
      end

      def config_files
        []
      end

      def remote_files
        [
          *config_files,
          {
            template: "#{script_name}.sh.erb",
            filename: 'install_script.sh'
          }
        ]
      end

      def install_commands
        [
          '/tmp/install_script.sh',
          *remote_files.map { |file| "rm /tmp/#{file[:filename]}" }
        ]
      end

      private

      def ssh_available?
        return true if system('which ssh', out: File::NULL)

        say_status 'error', 'SSH client not found. Please install SSH first.', :red
        false
      end

      def ssh_destination
        "#{options[:ssh_user]}@#{options[:ssh_host]}"
      end

      def ssh_options
        opts = [
          'StrictHostKeyChecking=accept-new',
          'ConnectTimeout=10'
        ]
        opts.map { |opt| "-o #{opt}" }.join(' ')
      end

      def installation_exists?(check_path)
        return false unless check_path

        "[ -d #{check_path} ]"
      end

      def execute_remote_commands(commands, options = {})
        if options[:key_path] && !File.exist?(File.expand_path(options[:key_path]))
          say_status 'error', "SSH key not found: #{options[:key_path]}", :red
          exit 1
        end

        title = options[:title] || 'Executing remote commands'
        say_status 'start', title, :blue

        script_content = []

        if options[:check_path] && !options[:force]
          script_content << <<~SHELL
            if #{installation_exists?(options[:check_path])}; then
              echo "Installation already exists at #{options[:check_path]}"
              echo "Use --force to reinstall"
              exit 0
            fi
          SHELL
        end

        script_content += commands.map do |cmd|
          <<~SHELL
            echo "→ Executing: #{cmd}"
            if ! #{cmd}; then
              echo "✗ Command failed: #{cmd}"
              exit 1
            fi
          SHELL
        end

        script_content << 'exit 0'

        ssh_cmd = ['ssh']
        ssh_cmd << "-i #{options[:key_path]}" if options[:key_path]
        ssh_cmd << ssh_options
        ssh_cmd << ssh_destination
        ssh_cmd << "'#{script_content.join("\n")}'"

        success = system(ssh_cmd.join(' '))

        if success
          say_status 'success', 'All commands completed successfully', :green
        else
          say_status 'error', "Command failed with exit status #{$CHILD_STATUS.exitstatus}", :red
          case $CHILD_STATUS.exitstatus
          when 255
            say '  → Could not connect to the server. Please check:', :red
            say '    • SSH host and user are correct'
            say '    • Your authentication credentials are valid'
            say '    • Server is reachable and SSH port (22) is open'
          when 126, 127
            say '  → Command not found or not executable', :red
            say '    • Ensure all required software is installed on the remote server'
          end
          exit $CHILD_STATUS.exitstatus
        end
      end
    end
  end
end
