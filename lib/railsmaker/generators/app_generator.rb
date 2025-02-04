# frozen_string_literal: true

module RailsMaker
  module Generators
    class AppGenerator < BaseGenerator
      source_root File.expand_path('templates/app', __dir__)

      argument :app_name
      argument :docker_username
      argument :ip_address
      argument :domain

      class_option :skip_daisyui, type: :boolean, default: false,
                                  desc: 'Skip frontend setup (Tailwind, DaisyUI)'

      REQUIRED_RAILS_VERSION = '8.0.1'

      def generate_app
        begin
          rails_version = Gem::Version.new(Rails.version)
          required_version = Gem::Version.new(REQUIRED_RAILS_VERSION)

          unless rails_version == required_version
            say_status 'error',
                       "Rails version #{rails_version} detected. RailsMaker requires Rails #{REQUIRED_RAILS_VERSION}", :red
            exit 1
          end
        rescue NameError
          say_status 'error', 'Rails is not installed. Please install Rails 8.0.1 first', :red
          exit 1
        end

        self.destination_root = File.expand_path(app_name, Dir.pwd)

        if File.directory?(File.expand_path(app_name, Dir.pwd))
          say_status 'error', "Directory '#{app_name}' already exists", :red
          exit 1
        end

        say('Creating new Rails app')
        rails_args = [app_name]
        rails_args << '--javascript=bun' unless options[:skip_daisyui]
        Rails::Generators::AppGenerator.start(rails_args)

        inside(destination_root) do
          setup_frontend unless options[:skip_daisyui]

          validate_gsub_strings([
                                  {
                                    file: 'config/deploy.yml',
                                    patterns: ['your-user', "web:\n    - 192.168.0.1", 'ssl: true', 'app.example.com']
                                  }
                                ])

          setup_kamal

          say('Modifying ApplicationController to allow all browsers (mobile)')
          comment_lines 'app/controllers/application_controller.rb', /allow_browser versions: :modern/

          say('Generating main controller with a landing page')
          generate :controller, 'main'

          if options[:skip_daisyui]
            create_file 'app/views/main/index.html.erb', "<h1>Welcome to #{app_name}</h1>"
          else
            copy_file 'main_index.html.erb', 'app/views/main/index.html.erb'
          end

          copy_file 'credentials.example.yml', 'config/credentials.example.yml'

          route "root 'main#index'"
        end

        say 'Successfully created Rails app with RailsMaker'
      rescue StandardError => e
        say_status 'error', "Failed to generate app: #{e.message}, check the file in #{destination_root}", :red
        exit 1
      end

      def git_commit
        git add: '.', commit: %(-m 'Initial railsmaker commit')
      end

      private

      def setup_frontend
        say('Adding Tailwind CSS')
        gem 'tailwindcss-rails', '~> 4.0.0.rc5'

        say('Installing gems')
        run 'bundle install'

        say('Setting up Tailwind')
        run 'bun add -d tailwindcss@4.0.0 @tailwindcss/cli@4.0.0'
        rails_command 'tailwindcss:install'

        say('Installing DaisyUI')
        run 'bun add -d daisyui@5.0.0-beta.2'

        validate_gsub_strings([
                                {
                                  file: 'app/views/layouts/application.html.erb',
                                  patterns: ['<main class="container mx-auto mt-28 px-5 flex">', '<html>']
                                },
                                {
                                  file: 'app/assets/tailwind/application.css',
                                  patterns: ['@import "tailwindcss";']
                                },
                                {
                                  file: 'Dockerfile',
                                  patterns: ['bun.lockb', 'RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile',
                                             '# Precompiling assets for production']
                                },
                                {
                                  file: 'app/views/layouts/application.html.erb',
                                  patterns: []
                                }
                              ])

        inject_into_file 'app/assets/tailwind/application.css', after: '@import "tailwindcss";' do
          <<~RUBY


            @plugin "daisyui" {
              themes: light --default, dark --prefersdark, cupcake;
            }
          RUBY
        end
        gsub_file 'app/views/layouts/application.html.erb', '<html>', '<html data-theme="cupcake">'
        gsub_file 'app/views/layouts/application.html.erb', '<main class="container mx-auto mt-28 px-5 flex">',
                  '<main>'

        say('Dockerfile: fixing legacy bun.lockb')
        gsub_file 'Dockerfile', 'bun.lockb', 'bun.lock'

        say('Dockerfile: fixing for Apple Silicon amd64 emulation')
        gsub_file 'Dockerfile',
                  'RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile',
                  'RUN TAILWINDCSS_INSTALL_DIR=node_modules/.bin SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile'
        inject_into_file 'Dockerfile', before: /# Precompiling assets for production/ do
          <<~RUBY
            # Ensure bun handles tailwind node bash binary
            RUN ln -s /usr/local/bun/bin/bun /usr/local/bun/bin/node\n
          RUBY
        end
      end

      def setup_kamal
        say('Configuring Kamal')

        gsub_file 'config/deploy.yml', 'your-user', docker_username
        gsub_file 'config/deploy.yml', "web:\n    - 192.168.0.1", "web:\n    hosts:\n      - #{ip_address}"
        gsub_file 'config/deploy.yml', 'app.example.com', domain
        inject_into_file 'config/deploy.yml', after: 'ssl: true' do
          "\n  forward_headers: true"
        end
      end
    end
  end
end
