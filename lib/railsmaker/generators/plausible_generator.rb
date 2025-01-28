# frozen_string_literal: true

module RailsMaker
  module Generators
    class PlausibleGenerator < ShellScriptGenerator
      argument :analytics_host, desc: 'Domain where Plausible will be hosted (e.g., plausible.example.com)'

      def initialize(*args)
        super
        options[:script_name] = 'plausible'
        options[:check_path] = '~/plausible-ce'
        options[:title] = "Installing Plausible Analytics on remote server #{ssh_user}@#{ssh_host}"
      end
    end
  end
end
