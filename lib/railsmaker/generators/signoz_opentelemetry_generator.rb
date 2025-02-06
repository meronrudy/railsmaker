# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozOpentelemetryGenerator < ShellScriptGenerator
      class_option :signoz_host, type: :string, required: true, desc: 'Host where SigNoz is running'
      class_option :override_hostname, type: :string, desc: 'Override the server hostname'

      def initialize(*args)
        super
        options[:script_name] = 'signoz_opentelemetry'
        options[:check_path] = '/etc/otelcol-contrib/config.yaml'
        options[:title] =
          "Installing SigNoz OpenTelemetry client on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"

        # Make signoz_host available to the template
        @signoz_host = options[:signoz_host]
        @override_hostname = options[:override_hostname]
      end

      def copy_config
        template 'otelcol_config.yaml.erb', '/tmp/otelcol_config.yaml'
      end

      private

      attr_reader :signoz_host, :override_hostname
    end
  end
end
