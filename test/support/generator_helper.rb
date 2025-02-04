# frozen_string_literal: true

require 'rails/generators/test_case'

module GeneratorHelper
  def setup
    prepare_destination
    copy_test_fixtures

    # Force overwrite of files for all generators
    RailsMaker::Generators::BaseGenerator.any_instance
                                         .stubs(:options)
                                         .returns(force: true)

    # Stub Rails application for configuration
    Rails.stubs(:application).returns(mock)
    Rails.application.stubs(:configure).yields(mock)
    Rails.application.stubs(:config).returns(mock)
    Rails.application.config.stubs(:lograge).returns(mock)

    # Stub git to prevent actual commits
    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:git)

    # Stub rails commands since we don't have a full Rails environment
    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:rails_command).returns(true)
    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:rake).returns(true)
    # RailsMaker::Generators::BaseGenerator.any_instance.stubs(:generate).returns(true)
  end

  private

  def copy_test_fixtures
    # Create all required directories
    mkdir_p('config/initializers')
    mkdir_p('lib/templates/opentelemetry')
    mkdir_p('app/views/layouts')
    mkdir_p('app/models')
    mkdir_p('db/migrate')

    # Create migration file that would be generated
    create_file 'db/migrate/20240101000000_add_omniauth_to_users.rb', <<~RUBY
      class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
        def change
          add_column :users, :provider, :string
          add_column :users, :uid, :string
        end
      end
    RUBY

    # Copy fixture files to destination
    copy_file(
      File.expand_path('../fixtures/opentelemetry/deploy.yml', __dir__),
      'config/deploy.yml'
    )
    copy_file(
      File.expand_path('../fixtures/auth/user.rb', __dir__),
      'app/models/user.rb'
    )

    # Copy template files
    copy_file(
      File.expand_path('../fixtures/opentelemetry/templates/lograge.rb.erb', __dir__),
      'lib/templates/opentelemetry/lograge.rb.erb'
    )

    # Create other required files
    create_file('Gemfile', "source 'https://rubygems.org'\n")
    create_file('config/environment.rb', "Rails.application.initialize!\n")
    create_file('config/routes.rb', <<~RUBY)
      Rails.application.routes.draw do
      end
    RUBY

    # Create layout with proper head section for scripts
    create_file('app/views/layouts/application.html.erb', <<~HTML)
      <!DOCTYPE html>
      <html>
        <head>
          <title>App</title>
          <%# Plausible Analytics %>
          <script defer data-domain="someapp" src="sample-src"></script>
          <script>window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }</script>
        </head>
        <body>
          <%= yield %>
        </body>
      </html>
    HTML

    # Create initializer files
    create_file('config/initializers/sentry.rb',
                "Sentry.init do |config|\n  config.dsn = ENV['SENTRY_DSN']\nend")
    create_file('config/initializers/clearance.rb',
                "Clearance.configure do |config|\n  config.mailer_sender = \"reply@example.com\"\nend")
    create_file('config/initializers/devise.rb',
                "Devise.setup do |config|\n  # Configuration here\nend")
    create_file('config/initializers/lograge.rb',
                "Rails.application.configure do\n  config.lograge.enabled = true\nend")
    create_file('config/initializers/omniauth.rb',
                "Rails.application.config.middleware.use OmniAuth::Builder do\n  # Providers will be configured here\nend")
  end

  def mkdir_p(path)
    FileUtils.mkdir_p(File.join(destination_root, path))
  end

  def copy_file(src, dest)
    FileUtils.cp(src, File.join(destination_root, dest))
  end

  def create_file(path, content)
    File.write(File.join(destination_root, path), content)
  end

  def assert_generator_git_commit(message)
    RailsMaker::Generators::BaseGenerator.any_instance
                                         .expects(:git)
                                         .with(add: '.', commit: %(-m '#{message}'))
  end
end
