# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozGenerator < ShellScriptGenerator
      def initialize(*args)
        super
        options[:script_name] = 'signoz'
        options[:check_path] = '~/signoz'
        options[:title] = "Installing SigNoz on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end
    end
  end
end
