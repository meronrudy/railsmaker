# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozOpentelemetryGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :signoz_host, type: :string, required: true, desc: 'Host where SigNoz is running'
      class_option :override_hostname, type: :string, desc: 'Override the server hostname'

      def initialize(*args)
        super

        @signoz_host = options[:signoz_host]
        @override_hostname = options[:override_hostname]
      end

      private

      def script_name
        'signoz_opentelemetry'
      end

      def check_path
        '/etc/otelcol-contrib/config.yaml'
      end

      def title
        "Installing SigNoz OpenTelemetry client on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end

      def config_files
        [
          {
            template: 'otelcol_config.yaml.erb',
            filename: 'otelcol_config.yaml'
          }
        ]
      end

      attr_reader :signoz_host, :override_hostname
    end
  end
end
