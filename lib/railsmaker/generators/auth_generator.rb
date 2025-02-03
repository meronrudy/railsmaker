module RailsMaker
  module Generators
    class AuthGenerator < BaseGenerator
      source_root File.expand_path('templates/auth', __dir__)

      argument :from_email, desc: 'Email address used for sending authentication emails'
      argument :host, desc: 'Host domain for the application'

      def add_gems
        gem_group :default do
          gem 'argon2', '2.3.0'
          gem 'clearance', '~> 2.9.3'
          gem 'omniauth', '~> 2.1.2'
          gem 'omniauth-google-oauth2', '~> 1.2.1'
          gem 'omniauth-rails_csrf_protection', '~> 1.0.2'
        end

        run 'bundle install'
      end

      def setup_clearance
        generate 'clearance:install'
        rake 'db:migrate'
        generate 'clearance:views'
      end

      def configure_clearance
        gsub_file 'config/initializers/clearance.rb',
                  'config.mailer_sender = "reply@example.com"',
                  "config.mailer_sender = \"#{from_email}\""

        inject_into_file 'config/initializers/clearance.rb', after: 'Clearance.configure do |config|' do
          "\n  config.redirect_url = \"/demo\""
        end
      end

      def setup_omniauth
        create_file 'config/initializers/omniauth.rb' do
          <<~RUBY
            # frozen_string_literal: true

            Rails.application.config.middleware.use OmniAuth::Builder do
              provider :google_oauth2,
                Rails.application.credentials.dig(:google_oauth, :client_id),
                Rails.application.credentials.dig(:google_oauth, :client_secret),
                {
                  scope: "email",
                  prompt: "select_account"
                }
            end

            OmniAuth.config.allowed_request_methods = %i[get]
          RUBY
        end

        generate 'migration', 'AddOmniauthToUsers provider:string uid:string'
        inject_into_file Dir['db/migrate/*add_omniauth_to_users.rb'].first,
                         after: "add_column :users, :uid, :string\n" do
          <<-RUBY
    add_index :users, [:provider, :uid], unique: true
          RUBY
        end

        inject_into_file 'app/models/user.rb', after: "include Clearance::User\n" do
          <<-RUBY

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = SecureRandom.hex(10)
    end
  end
          RUBY
        end

        rake 'db:migrate'
      end

      def add_omniauth_controller
        template 'app/controllers/omniauth_callbacks_controller.rb',
                 'app/controllers/omniauth_callbacks_controller.rb'
      end

      def update_routes
        route <<~RUBY
          # OmniAuth callback routes
          get "auth/:provider/callback", to: "omniauth_callbacks#google_oauth2", constraints: { provider: "google_oauth2" }
          get 'auth/failure', to: 'omniauth_callbacks#failure'
        RUBY
      end

      def git_commit
        git add: '.', commit: %(-m 'Add authentication with Clearance and OmniAuth')
      end
    end
  end
end
