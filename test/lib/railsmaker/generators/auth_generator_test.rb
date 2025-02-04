# frozen_string_literal: true

require 'test_helper'

class AuthGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::AuthGenerator
  destination File.expand_path('../../tmp', __dir__)

  def setup
    super
    # Create migration file that would be generated
    mkdir_p('db/migrate')
    @migration_path = 'db/migrate/20240101000000_add_omniauth_to_users.rb'
    create_file @migration_path, <<~RUBY
      class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
        def change
          add_column :users, :provider, :string
          add_column :users, :uid, :string
        end
      end
    RUBY

    # Stub the migration file lookup
    Dir.stubs(:[]).with('db/migrate/*add_omniauth_to_users.rb').returns([@migration_path])
  end

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_configures_authentication
    run_generator %w[test@example.com example.com]

    # Verify gems are added
    assert_file 'Gemfile' do |content|
      assert_match(/gem "argon2", "2.3.0"/, content)
      assert_match(/gem "clearance", "~> 2.9.3"/, content)
      assert_match(/gem "omniauth", "~> 2.1.2"/, content)
      assert_match(/gem "omniauth-google-oauth2", "~> 1.2.1"/, content)
      assert_match(/gem "omniauth-rails_csrf_protection", "~> 1.0.2"/, content)
    end

    # Verify clearance configuration
    assert_file 'config/initializers/clearance.rb' do |content|
      assert_match(/config.mailer_sender = Rails.application.credentials.dig\(:app, :mailer_sender\)/, content)
      assert_match(%r{config.redirect_url = "/demo"}, content)
    end

    # Verify omniauth configuration
    assert_file 'config/initializers/omniauth.rb' do |content|
      assert_match(/provider :google_oauth2/, content)
      assert_match(/Rails.application.credentials.dig\(:google_oauth, :client_id\)/, content)
      assert_match(/Rails.application.credentials.dig\(:google_oauth, :client_secret\)/, content)
    end

    # Verify routes
    assert_file 'config/routes.rb' do |content|
      assert_match(%r{get "auth/:provider/callback"}, content)
      assert_match(%r{get 'auth/failure'}, content)
    end
  end
end
