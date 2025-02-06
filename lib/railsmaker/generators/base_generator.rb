# frozen_string_literal: true

module RailsMaker
  module Generators
    class BaseGenerator < Rails::Generators::Base
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
    end
  end
end
