# frozen_string_literal: true

require 'test_helper'

class AuthGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::AuthGenerator
  destination File.expand_path('../../tmp', __dir__)

  def setup
    super

    # Stub the migration file lookup
    migration_path = 'db/migrate/20240101000000_add_omniauth_to_users.rb'
    Dir.stubs(:[]).with('db/migrate/*add_omniauth_to_users.rb').returns([migration_path])
  end

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_configures_authentication
    run_generator %w[--mailer_sender=test@example.com]

    assert_file 'Gemfile' do |content|
      assert_match(/gem "clearance", "~> 2.9.3"/, content)
      assert_match(/gem "omniauth", "~> 2.1.2"/, content)
      assert_match(/gem "omniauth-google-oauth2", "~> 1.2.1"/, content)
      assert_match(/gem "omniauth-rails_csrf_protection", "~> 1.0.2"/, content)
    end

    assert_file 'config/initializers/clearance.rb' do |content|
      assert_match(/config.mailer_sender = Rails.application.credentials.dig\(:app, :mailer_sender\)/, content)
      assert_match(%r{config.redirect_url = "/demo"}, content)
    end

    assert_file 'config/initializers/omniauth.rb' do |content|
      assert_match(/provider :google_oauth2/, content)
      assert_match(/Rails.application.credentials.dig\(:google_oauth, :client_id\)/, content)
      assert_match(/Rails.application.credentials.dig\(:google_oauth, :client_secret\)/, content)
    end

    assert_file 'app/models/user.rb' do |content|
      assert_match(/include Clearance::User/, content)
      assert_match(/from_omniauth\(auth\)/, content)
    end

    assert_file 'app/controllers/omniauth_callbacks_controller.rb' do |content|
      assert_match(/class OmniauthCallbacksController < ApplicationController/, content)
      assert_match(/def google_oauth2/, content)
      assert_match(/redirect_to demo_url/, content)
    end

    assert_file 'config/routes.rb' do |content|
      assert_match(
        %r{get "auth/:provider/callback", to: "omniauth_callbacks#google_oauth2", constraints: { provider: "google_oauth2" }}, content
      )
      assert_match(%r{get 'auth/failure', to: 'omniauth_callbacks#failure'}, content)
    end
  end

  def test_generator_with_custom_email
    run_generator %w[--mailer_sender=custom@example.com]
    assert_file 'config/initializers/clearance.rb' do |content|
      assert_match(/config.mailer_sender = Rails.application.credentials.dig\(:app, :mailer_sender\)/, content)
      assert_match(%r{config.redirect_url = "/demo"}, content)
    end

    assert_file 'config/initializers/omniauth.rb' do |content|
      assert_match(/provider :google_oauth2/, content)
    end

    assert_file 'app/controllers/omniauth_callbacks_controller.rb' do |content|
      assert_match(/redirect_to demo_url/, content)
    end
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add authentication with Clearance and OmniAuth')
    run_generator %w[--mailer_sender=test@example.com]
  end

  def test_generator_creates_user_model_with_omniauth
    run_generator %w[--mailer_sender=test@example.com]
    assert_file 'app/models/user.rb' do |content|
      assert_match(/def self.from_omniauth\(auth\)/, content)
      assert_match(/user.email = auth.info.email/, content)
      assert_match(/user.password = SecureRandom.hex\(10\)/, content)
    end
  end

  def test_generator_creates_migration_with_indices
    run_generator %w[--mailer_sender=test@example.com]
    migration_file = Dir['db/migrate/*add_omniauth_to_users.rb'].first
    assert_file migration_file do |content|
      assert_match(/add_column :users, :provider, :string/, content)
      assert_match(/add_column :users, :uid, :string/, content)
      assert_match(/add_index :users, \[:provider, :uid\], unique: true/, content)
    end
  end
end
