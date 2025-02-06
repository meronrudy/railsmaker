# frozen_string_literal: true

module RailsMaker
  module Generators
    class MailjetGenerator < BaseGenerator
      source_root File.expand_path('templates/mailjet', __dir__)

      class_option :name, type: :string, required: true, desc: 'Name of the service for email sender'
      class_option :domain, type: :string, required: true, desc: 'Host domain for the application'

      def initialize(*args)
        super
        @name = options[:name]
        @domain = options[:domain]
      end

      def add_gem
        gem_group :default do
          gem 'mailjet', '~> 1.8'
        end

        run 'bundle install'
      end

      def create_initializer
        create_file 'config/initializers/mailjet.rb' do
          <<~RUBY
            # frozen_string_literal: true

            Mailjet.configure do |config|
              config.api_key = Rails.application.credentials.dig(:mailjet, :api_key)
              config.secret_key = Rails.application.credentials.dig(:mailjet, :secret_key)
              config.default_from = Rails.application.credentials.dig(:app, :mailer_sender)
              config.api_version = "v3.1"
            end
          RUBY
        end
      end

      def configure_mailer
        environment(nil, env: 'production') do
          <<~RUBY
            # Mailjet API configuration
            config.action_mailer.delivery_method = :mailjet_api
          RUBY
        end

        gsub_file 'app/mailers/application_mailer.rb',
                  /default from: .+$/,
                  'default from: Rails.application.credentials.dig(:app, :mailer_sender)'

        gsub_file 'config/environments/production.rb',
                  /config\.action_mailer\.default_url_options = \{ host: .+\}/,
                  'config.action_mailer.default_url_options = { host: Rails.application.credentials.dig(:app, :host) }'
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Mailjet configuration')

        say 'Successfully added Mailjet configuration', :green
      end

      private

      attr_reader :name, :domain
    end
  end
end
