# frozen_string_literal: true

module RailsMaker
  module Generators
    class BaseGenerator < Rails::Generators::Base
      class BaseGeneratorError < StandardError; end

      include Rails::Generators::Actions
      include GsubValidation

      def self.default_command_options
        { abort_on_failure: true }
      end

      protected

      def run(*args)
        options = args.extract_options!
        options = self.class.default_command_options.merge(options)
        super(*args, options.merge(force: true)) # do not ask for confirmation on overrides
      end

      private

      def check_required_env_vars(required_vars)
        missing_vars = required_vars.reject { |var| ENV[var].present? }

        return if missing_vars.empty?

        say "\nError: Missing required environment variables:", :red
        missing_vars.each { |var| say "  - #{var}", :red }
        say "\nPlease set these environment variables before continuing:", :red
        missing_vars.each { |var| say "  export #{var}=your-value", :yellow }

        raise BaseGeneratorError, 'Missing required environment variables'
      end
    end
  end
end
