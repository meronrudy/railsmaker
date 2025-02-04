# frozen_string_literal: true

module RailsMaker
  module Generators
    class UiGenerator < BaseGenerator
      source_root File.expand_path('templates/ui', __dir__)

      argument :host, desc: 'Host domain for the application'
      argument :app_name, desc: 'Name of the application'

      def add_seo_capabilities
        # Add sitemap_generator gem
        gem 'sitemap_generator', '6.3.0'

        # Install sitemap generator
        rails_command 'sitemap:install'

        # Modify Dockerfile to include sitemap generation
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
      end
    end
  end
end
