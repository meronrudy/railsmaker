# frozen_string_literal: true

module RailsMaker
  module Generators
    class AppFullGenerator < BaseGenerator
      argument :app_name
      argument :docker_username
      argument :ip_address
      argument :domain
      argument :analytics_domain
      argument :from_name
      argument :from_email
      argument :bucket_name

      class_option :skip_daisyui, type: :boolean, default: false,
                                  desc: 'Skip frontend setup (Tailwind, DaisyUI)'

      def generate_app
        RailsMaker::Generators::AppGenerator.new(
          [app_name, docker_username, ip_address, domain],
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

          # Setup Plausible
          RailsMaker::Generators::PlausibleInstrumentationGenerator.new(
            [domain, analytics_domain],
            destination_root: destination_root
          ).invoke_all

          # Setup Sentry
          RailsMaker::Generators::SentryGenerator.new(
            destination_root: destination_root
          ).invoke_all

          unless options[:skip_daisyui]
            # Setup Auth
            RailsMaker::Generators::AuthGenerator.new(
              [from_email, domain],
              destination_root: destination_root
            ).invoke_all

            # Setup UI
            RailsMaker::Generators::UiGenerator.new(
              [domain],
              destination_root: destination_root
            ).invoke_all
          end

          # Setup Mailjet
          RailsMaker::Generators::MailjetGenerator.new(
            [from_name, from_email, domain],
            destination_root: destination_root
          ).invoke_all

          # Setup Litestream
          RailsMaker::Generators::LitestreamGenerator.new(
            [bucket_name, app_name, ip_address],
            destination_root: destination_root
          ).invoke_all

          say('Successfully added all integrations 🎉')
        end
      end
    end
  end
end
