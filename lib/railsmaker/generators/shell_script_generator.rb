require_relative "server_command_generator"

module RailsMaker
  module Generators
    class ShellScriptGenerator < ServerCommandGenerator
      source_root File.expand_path("templates/shell_scripts", __dir__)
      
      class_option :script_name, type: :string, required: true,
                  desc: "Name of the shell script template to use"
      class_option :check_path, type: :string,
                  desc: "Path to check for existing installation"
      class_option :title, type: :string,
                  desc: "Title to display during execution"
      
      def execute_script
        return unless ssh_available?

        template "#{options[:script_name]}.sh.erb", "/tmp/install_script.sh"
        execute_remote_commands([
          "chmod +x /tmp/install_script.sh",
          "/tmp/install_script.sh",
          "rm /tmp/install_script.sh"
        ],
          title: options[:title],
          check_path: options[:check_path],
          force: options[:force]
        )
      end
    end
  end
end 