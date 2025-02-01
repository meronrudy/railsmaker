# frozen_string_literal: true

module RailsMaker
  module Generators
    class SentryGenerator < BaseGenerator
      def add_gems
        gem_group :default do
          gem 'sentry-ruby', '~> 5.22.3'
          gem 'sentry-rails', '~> 5.22.3'
        end

        run 'bundle install'
      end

      def generate_sentry_initializer
        generate 'sentry'

        validations = [
          {
            file: 'config/initializers/sentry.rb',
            patterns: [
              'Sentry.init'
            ]
          }
        ]

        validate_gsub_strings(validations)
      end

      def configure_sentry
        gsub_file 'config/initializers/sentry.rb', /Sentry\.init.*end\n/m do
          <<~RUBY
            Sentry.init do |config|
              config.dsn = Rails.application.credentials.dig(:sentry_dsn)
              config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
            end
          RUBY
        end
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Sentry')
      end
    end
  end
end
