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
    # Create all required directories under the destination root.
    %w[
      config/initializers
      config
      lib/templates/opentelemetry
      app/views/layouts
      app/models
      db/migrate
    ].each { |dir| mkdir_p(dir) }

    # Copy fixture files from the test/fixtures directory.
    copy_file fixture_path('db/migrate/add_omniauth_to_users.rb'),
              'db/migrate/20240101000000_add_omniauth_to_users.rb'

    copy_file fixture_path('Gemfile'),
              'Gemfile'

    copy_file fixture_path('config/environment.rb'),
              'config/environment.rb'

    copy_file fixture_path('config/routes.rb'),
              'config/routes.rb'

    copy_file fixture_path('app/views/layouts/application.html.erb'),
              'app/views/layouts/application.html.erb'

    copy_file fixture_path('config/initializers/sentry.rb'),
              'config/initializers/sentry.rb'

    copy_file fixture_path('config/initializers/clearance.rb'),
              'config/initializers/clearance.rb'

    copy_file fixture_path('config/initializers/devise.rb'),
              'config/initializers/devise.rb'

    copy_file fixture_path('config/initializers/lograge.rb'),
              'config/initializers/lograge.rb'

    copy_file fixture_path('config/initializers/omniauth.rb'),
              'config/initializers/omniauth.rb'

    copy_file fixture_path('auth/user.rb'),
              'app/models/user.rb'

    copy_file fixture_path('config/deploy.yml'),
              'config/deploy.yml'
  end

  def fixture_path(rel_path)
    File.expand_path(File.join('test', 'fixtures', rel_path))
  end

  def mkdir_p(path)
    FileUtils.mkdir_p(File.join(destination_root, path))
  end

  def copy_file(src, dest)
    FileUtils.cp(src, File.join(destination_root, dest))
  end

  def assert_generator_git_commit(message)
    RailsMaker::Generators::BaseGenerator.any_instance
                                         .expects(:git)
                                         .with(add: '.', commit: %(-m '#{message}'))
  end
end
