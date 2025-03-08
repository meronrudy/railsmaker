# frozen_string_literal: true

module RailsMaker
  module Generators
    class AppGenerator < BaseGenerator
      source_root File.expand_path('templates/app', __dir__)

      class_option :name, type: :string, required: true, desc: 'Name of the application'
      class_option :docker, type: :string, required: true, desc: 'Docker username'
      class_option :ip, type: :string, required: true, desc: 'Server IP address'
      class_option :domain, type: :string, required: true, desc: 'Domain name'
      class_option :ui, type: :boolean, default: false, desc: 'Include UI assets?'
      class_option :registry_url, type: :string, desc: 'Custom Docker registry URL (e.g., registry.digitalocean.com)'

      def check_required_env_vars
        super(%w[
          KAMAL_REGISTRY_PASSWORD
        ])
      end

      def generate_app
        self.destination_root = File.expand_path(options[:name], current_dir)

        if !in_minitest? && File.directory?(destination_root)
          say_status 'error', "Directory '#{options[:name]}' already exists", :red
          raise BaseGeneratorError, 'Directory already exists'
        end

        say('Creating new Rails app')
        rails_args = [options[:name]]
        rails_args << '--javascript=bun' if options[:ui]
        Rails::Generators::AppGenerator.start(rails_args)

        setup_frontend if options[:ui]

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

        if options[:ui]
          copy_file 'main_index.html.erb', 'app/views/main/index.html.erb'
        else
          create_file 'app/views/main/index.html.erb', "<h1>Welcome to #{options[:name]}</h1>"
        end

        copy_file 'credentials.example.yml', 'config/credentials.example.yml'

        route "root 'main#index'"
      rescue StandardError => e
        say_status 'error', "Failed to generate app: #{e.message} in #{destination_root}", :red
        raise BaseGeneratorError, e.message
      end

      def git_commit
        git add: '.', commit: %(-m 'Initial railsmaker commit')

        say 'Successfully created Rails app with RailsMaker', :green
      end

      private

      def setup_frontend
        say('Adding Tailwind CSS')
        gem 'tailwindcss-rails', '~> 4.2.0'

        say('Installing gems')
        run 'bundle install --quiet'

        say('Setting up Tailwind')
        run 'bun add -d tailwindcss@4.0.12 @tailwindcss/cli@4.0.12'
        rails_command 'tailwindcss:install'

        say('Installing DaisyUI')
        run 'bun add -d daisyui@5.0.0'

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

        inject_into_file 'config/deploy.yml', after: 'service: railsmaker' do
          "\ndeploy_timeout: 60 # to avoid timeout on first deploy"
        end
        gsub_file 'config/deploy.yml', 'your-user', options[:docker]
        gsub_file 'config/deploy.yml', "web:\n    - 192.168.0.1", "web:\n    hosts:\n      - #{options[:ip]}"
        gsub_file 'config/deploy.yml', 'app.example.com', options[:domain]
        inject_into_file 'config/deploy.yml', after: 'ssl: true' do
          "\n  forward_headers: true"
        end

        return unless options[:registry_url]

        uncomment_lines 'config/deploy.yml', 'server: registry.digitalocean.com'
        gsub_file 'config/deploy.yml', 'registry.digitalocean.com / ghcr.io / ...', options[:registry_url]
      end

      def current_dir
        Dir.pwd
      end

      def in_minitest?
        defined?(Minitest)
      end
    end
  end
end
