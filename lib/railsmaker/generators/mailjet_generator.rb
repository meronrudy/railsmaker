module RailsMaker
  module Generators
    class MailjetGenerator < BaseGenerator
      source_root File.expand_path('templates/mailjet', __dir__)

      argument :from_name, desc: 'Name of the service for email sender'
      argument :from_email, desc: 'Email address used for sending emails'
      argument :host, desc: 'Host domain for the application'

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
              config.default_from = '#{from_name} <#{from_email}>'
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
                  "default from: '#{from_name} <#{from_email}>'"

        gsub_file 'config/environments/production.rb',
                  /config\.action_mailer\.default_url_options = \{ host: .+\}/,
                  "config.action_mailer.default_url_options = { host: '#{host}' }"
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Mailjet configuration')
      end
    end
  end
end 