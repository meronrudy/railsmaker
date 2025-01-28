module RailsMaker
  module Generators
    class OpentelemetryGenerator < BaseGenerator
      source_root File.expand_path("templates/opentelemetry", __dir__)
      
      argument :service_name, desc: "Name of the service for OpenTelemetry"

      def add_kamal_config
        inject_into_file "config/deploy.yml", after: "web:\n" do
          <<-YAML
    options:
      "add-host": host.docker.internal:host-gateway
YAML
        end

        inject_into_file "config/deploy.yml", after: "SOLID_QUEUE_IN_PUMA: true\n" do
          <<-YAML
    # OpenTelemetry env vars
    OTEL_EXPORTER: otlp
    OTEL_SERVICE_NAME: #{service_name}
    OTEL_EXPORTER_OTLP_ENDPOINT: http://host.docker.internal:4318
          YAML
        end
      end

      def add_gems
        gem_group :default do
          gem 'opentelemetry-sdk'
          gem 'opentelemetry-exporter-otlp'
          gem 'opentelemetry-instrumentation-all'

          gem 'lograge'
          gem 'logstash-event'
        end

        run "bundle install"
      end

      def configure_opentelemetry
        environment_file = "config/environment.rb"
        
        # Add require at the top
        prepend_to_file environment_file, "require 'opentelemetry/sdk'\n"
        
        # Add configuration after Rails.application.initialize!
        inject_into_file environment_file, before: "Rails.application.initialize!" do
          <<~RUBY

            OpenTelemetry::SDK.configure do |c|
              c.use_all
            end

          RUBY
        end
      end

      def setup_lograge
        template "lograge.rb.erb", "config/initializers/lograge.rb"
      end
    end
  end
end 