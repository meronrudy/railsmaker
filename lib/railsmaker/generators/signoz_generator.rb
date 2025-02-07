# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      private

      def script_name
        'signoz'
      end

      def check_path
        '~/signoz'
      end

      def title
        "Installing SigNoz on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end
    end
  end
end
