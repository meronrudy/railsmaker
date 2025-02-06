# frozen_string_literal: true

module RailsMaker
  module Generators
    class PlausibleGenerator < ShellScriptGenerator
      def initialize(*args)
        super
        options[:script_name] = 'plausible'
        options[:check_path] = '~/plausible-ce'
        options[:title] = "Installing Plausible Analytics on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"

        # Make analytics_host available to the template
        @analytics_host = options[:analytics_host]
      end

      private

      attr_reader :analytics_host
    end
  end
end
