# frozen_string_literal: true

require 'rails/generators/test_case'

module GeneratorHelper
  def setup
    prepare_destination
    copy_test_fixtures

    RailsMaker::Generators::BaseGenerator.any_instance
                                         .stubs(:options)
                                         .returns(force: true)

    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:git).returns(true)
    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:rails_command).returns(true)
    RailsMaker::Generators::BaseGenerator.any_instance.stubs(:rake).returns(true)
  end

  def copy_test_fixtures(subfolder = nil)
    base_dest = subfolder ? File.join(destination_root, subfolder) : destination_root

    # Create all required directories under the base destination.
    %w[
      .kamal
      config
      config/environments
      config/initializers
      lib/templates/opentelemetry
      lib/templates/config
      app/assets/tailwind
      app/controllers
      app/mailers
      app/models
      app/views/layouts
      lib/templates/app/views/main
      db/migrate
    ].each do |dir|
      mkdir_p File.join(base_dest, dir)
    end

    # Fixtures are for files created by other generators
    copy_file fixture_path('db/migrate/add_omniauth_to_users.rb'),
              File.join(base_dest, 'db/migrate/20240101000000_add_omniauth_to_users.rb')

    copy_file fixture_path('Gemfile'), File.join(base_dest, 'Gemfile')
    copy_file fixture_path('Dockerfile'), File.join(base_dest, 'Dockerfile')
    copy_file fixture_path('.kamal/secrets'), File.join(base_dest, '.kamal/secrets')
    copy_file fixture_path('config/environment.rb'), File.join(base_dest, 'config/environment.rb')
    copy_file fixture_path('config/environments/production.rb'),
              File.join(base_dest, 'config/environments/production.rb')
    copy_file fixture_path('config/routes.rb'), File.join(base_dest, 'config/routes.rb')
    copy_file fixture_path('app/views/layouts/application.html.erb'),
              File.join(base_dest, 'app/views/layouts/application.html.erb')
    copy_file fixture_path('app/controllers/application_controller.rb'),
              File.join(base_dest, 'app/controllers/application_controller.rb')
    copy_file fixture_path('config/initializers/sentry.rb'), # sentry generator creates this file
              File.join(base_dest, 'config/initializers/sentry.rb')
    copy_file fixture_path('config/initializers/clearance.rb'), # clearance generator creates this file
              File.join(base_dest, 'config/initializers/clearance.rb')
    copy_file fixture_path('config/initializers/devise.rb'),
              File.join(base_dest, 'config/initializers/devise.rb')
    copy_file fixture_path('config/initializers/lograge.rb'),
              File.join(base_dest, 'lib/templates/opentelemetry/lograge.rb')
    copy_file fixture_path('auth/user.rb'), File.join(base_dest, 'app/models/user.rb')
    copy_file fixture_path('config/deploy.yml'), File.join(base_dest, 'config/deploy.yml')
    copy_file fixture_path('app/credentials.example.yml'),
              File.join(base_dest, 'lib/templates/config/credentials.example.yml')
    copy_file fixture_path('app/views/main/index.html.erb'),
              File.join(base_dest, 'lib/templates/app/views/main/index.html.erb')
    copy_file fixture_path('app/assets/tailwind/application.css'),
              File.join(base_dest, 'app/assets/tailwind/application.css')
    copy_file fixture_path('app/mailers/application_mailer.rb'),
              File.join(base_dest, 'app/mailers/application_mailer.rb')
  end

  private

  def fixture_path(rel_path)
    File.expand_path(File.join('test', 'fixtures', rel_path))
  end

  def mkdir_p(path)
    FileUtils.mkdir_p(path)
  end

  def copy_file(src, dest)
    FileUtils.cp(src, dest)
  end

  def assert_generator_git_commit(message)
    RailsMaker::Generators::BaseGenerator.any_instance
                                         .expects(:git)
                                         .with(add: '.', commit: %(-m '#{message}'))
  end
end
