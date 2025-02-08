# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :signoz_version, type: :string, default: 'v0.71.0',
                                    desc: 'Version of SigNoz to install'

      def initialize(*args)
        super
        @signoz_version = options[:signoz_version]
      end

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

      attr_reader :signoz_version
    end
  end
end
