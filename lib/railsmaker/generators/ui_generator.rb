# frozen_string_literal: true

module RailsMaker
  module Generators
    class UiGenerator < BaseGenerator
      source_root File.expand_path('templates/ui', __dir__)

      class_option :domain, type: :string, required: true, desc: 'Host domain for the application'
      class_option :name, type: :string, required: true, desc: 'Name of the application'
      class_option :analytics, type: :string, desc: 'Domain where Plausible is hosted'
      class_option :sentry, type: :boolean, default: false, desc: 'Wether Sentry is enabled'

      attr_reader :domain, :name, :host, :app_name, :plausible_enabled, :sentry_enabled

      def initialize(*args)
        super

        @host = options[:domain]
        @app_name = options[:name]
        @plausible_enabled = options[:analytics].present?
        @sentry_enabled = options[:sentry]
      end

      def add_seo_capabilities
        gem 'sitemap_generator', '6.3.0'

        rails_command 'sitemap:install'

        inject_into_file 'Dockerfile', after: "./bin/rails assets:precompile\n" do
          "\n# Generate sitemap\nRUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails sitemap:refresh\n"
        end
      end

      def copy_views
        directory 'app/views', 'app/views', force: true
        directory 'app/assets/images', 'app/assets/images', force: true
        directory 'app/controllers', 'app/controllers', force: true
        directory 'app/helpers', 'app/helpers', force: true
        directory 'app/javascript', 'app/javascript', force: true
        directory 'public', 'public', force: true

        template 'app/views/layouts/application.html.erb', 'app/views/layouts/application.html.erb', force: true
        template 'config/sitemap.rb', 'config/sitemap.rb', force: true
        template 'public/robots.txt', 'public/robots.txt', force: true
        template 'app/views/shared/_structured_data.html.erb', 'app/views/shared/_structured_data.html.erb', force: true
      end

      def add_routes
        route <<~ROUTES
          # Demo pages
          get "demo", to: "demo#index", as: :demo
          get "analytics", to: "demo#analytics", as: :analytics
          get "support", to: "demo#support", as: :support

          # Static pages
          get "privacy", to: "pages#privacy", as: :privacy
          get "terms", to: "pages#terms", as: :terms
        ROUTES
      end

      def git_commit
        git add: '.', commit: %(-m 'Add sample UI layer')

        say 'Successfully added sample UI layer', :green
      end
    end
  end
end
