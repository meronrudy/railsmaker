# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozOpentelemetryGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :signoz_server_host, type: :string, required: true, desc: 'Host where SigNoz is running'
      class_option :hostname, type: :string, desc: 'Override the server hostname'
      class_option :signoz_version, type: :string, default: 'v0.71.0',
                                    desc: 'Version of SigNoz to install'

      def initialize(*args)
        super
        @signoz_server_host = options[:signoz_server_host]
        @hostname = options[:hostname]
        @signoz_version = options[:signoz_version]
      end

      private

      def script_name
        'signoz_opentelemetry'
      end

      def check_path
        '~/signoz-opentelemetry'
      end

      def title
        "Installing SigNoz OpenTelemetry client on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end

      attr_reader :signoz_server_host, :hostname, :signoz_version
    end
  end
end
