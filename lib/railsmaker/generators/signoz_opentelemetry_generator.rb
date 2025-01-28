# frozen_string_literal: true

module RailsMaker
  module Generators
    class SignozOpentelemetryGenerator < ShellScriptGenerator
      argument :signoz_host, desc: 'Host where SigNoz is running'
      class_option :override_hostname, type: :string, desc: 'Override the server hostname'

      def initialize(*args)
        super
        options[:script_name] = 'signoz_opentelemetry'
        options[:check_path] = '/etc/otelcol-contrib/config.yaml'
        options[:title] = "Installing SigNoz OpenTelemetry client on remote server #{ssh_user}@#{ssh_host}"
      end

      def copy_config
        template 'otelcol_config.yaml.erb', '/tmp/otelcol_config.yaml'
      end
    end
  end
end
