# Rails gems
require "rails/generators"
require "rails/generators/rails/app/app_generator"

# Local generators
require "railsmaker/generators/base_generator"
require "railsmaker/generators/shell_script_generator"
require "railsmaker/generators/server_command_generator"

# App generators
require "railsmaker/generators/app_generator"
require "railsmaker/generators/docker_generator"
require "railsmaker/generators/plausible_generator"
require "railsmaker/generators/signoz_generator"
require "railsmaker/generators/signoz_opentelemetry_generator"
require "railsmaker/generators/opentelemetry_generator"
require "railsmaker/generators/plausible_instrumentation_generator"

module RailsMaker
  VERSION = "0.0.1"
end