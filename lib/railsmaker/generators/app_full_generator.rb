# frozen_string_literal: true

module RailsMaker
  module Generators
    class AppFullGenerator < BaseGenerator
      argument :app_name
      argument :docker_username
      argument :ip_address
      argument :hostname # Used for both app domain and deployment hostname
      argument :analytics_domain
      argument :sentry_dsn

      class_option :skip_daisyui, type: :boolean, default: false,
                                  desc: 'Skip frontend setup (Tailwind, DaisyUI)'

      def generate_app
        RailsMaker::Generators::AppGenerator.new(
          [app_name, docker_username, ip_address, hostname],
          skip_daisyui: options[:skip_daisyui],
          destination_root: destination_root
        ).invoke_all
      end

      def setup_integrations
        inside(app_name) do
          # Ensure bundle install is run first
          run 'bundle install'

          # Setup OpenTelemetry
          RailsMaker::Generators::OpentelemetryGenerator.new(
            [app_name],
            destination_root: destination_root
          ).invoke_all
          git add: '.', commit: %(-m 'Add OpenTelemetry')

          # Setup Plausible
          RailsMaker::Generators::PlausibleInstrumentationGenerator.new(
            [hostname, analytics_domain],
            destination_root: destination_root
          ).invoke_all
          git add: '.', commit: %(-m 'Add Plausible Analytics')

          # Setup Sentry
          RailsMaker::Generators::SentryGenerator.new(
            [sentry_dsn],
            destination_root: destination_root
          ).invoke_all
          git add: '.', commit: %(-m 'Add Sentry')
        end
      end
    end
  end
end
