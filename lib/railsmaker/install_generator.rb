# lib/railsmaker/install_generator.rb
require "rails/generators"
require "rails/generators/app_base"
require 'rails/generators/rails/app/app_generator'

module RailsMaker
  class InstallGenerator < Rails::Generators::AppBase
    include Rails::Generators::Actions
    source_root File.expand_path('templates', __dir__)

    argument :app_name
    argument :docker_username
    argument :ip_address
    argument :hostname

    def create_app
      self.destination_root = File.expand_path(app_name, Dir.pwd)

      say("Creating new Rails app")
      Rails::Generators::AppGenerator.start([
        app_name,
        "--javascript=bun",
      ])

      inside(destination_root) do
        say("Adding Tailwind CSS")
        gem "tailwindcss-rails", "4.0.0.rc1"
        
        say("Installing gems")
        run "bundle install"
        
        say("Setting up Tailwind")
        run "bun add -d tailwindcss @tailwindcss/cli"
        rails_command "tailwindcss:install"

        say("Installing DaisyUI")
        run "bun add -d daisyui@beta"
        inject_into_file "app/assets/stylesheets/application.tailwind.css", after: "@import \"tailwindcss\";" do
          <<~RUBY

            @plugin "daisyui" {
              themes: light --default, dark --prefersdark, cupcake;
            }
          RUBY
        end
        gsub_file "app/views/layouts/application.html.erb", "<html>", "<html data-theme=\"cupcake\">"
        gsub_file "app/views/layouts/application.html.erb", "<main class=\"container mx-auto mt-28 px-5 flex\">", "<main>"

        say("Dockerfile: fixing legacy bun.lockb")
        gsub_file "Dockerfile", "bun.lockb", "bun.lock" # TODO: Remove this once bun.lockb is fixed

        say("Dockerfile: fixing for Apple Silicon amd64 emulation")
        gsub_file "Dockerfile", 
          'RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile',
          'RUN TAILWINDCSS_INSTALL_DIR=node_modules/.bin SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile'
        inject_into_file "Dockerfile", before: /# Precompiling assets for production/ do
          <<~RUBY
            # Ensure bun handles tailwind node bash binary
            RUN ln -s /usr/local/bun/bin/bun /usr/local/bun/bin/node\n\n
          RUBY
        end

        say("Configuring Kamal")
        run "kamal init"
        gsub_file "config/deploy.yml", "your-user", docker_username
        gsub_file "config/deploy.yml", "my_app", app_name.underscore
        gsub_file "config/deploy.yml", "192.168.0.1", ip_address
        gsub_file "config/deploy.yml", "app.example.com", hostname
        inject_into_file "config/deploy.yml", after: "ssl: true" do
          "\n  forward_headers: true\n"
        end

        say("Modifying ApplicationControlle to allow all browsers (mobile)")
        comment_lines "app/controllers/application_controller.rb", /allow_browser versions: :modern/

        say("Generating main controller with a landing page")
        generate :controller, "main"
        copy_file "main_index.html.erb", "app/views/main/index.html.erb"
        route "root 'main#index'"

        say("Committing to git")
        git add: ".", commit: %(-m 'Initial railsmaker commit')
      end

      say "Successfully created Rails app with RailsMaker"
    end
  end
end