# frozen_string_literal: true

module RailsMaker
  module Generators
    class PlausibleGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :analytics_host, type: :string, required: true,
                                    desc: 'Domain where Plausible Analytics will be hosted'

      def initialize(*args)
        super
        @analytics_host = options[:analytics_host]
      end

      private

      def script_name
        'plausible'
      end

      def check_path
        '~/plausible-ce'
      end

      def title
        "Installing Plausible Analytics on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end

      attr_reader :analytics_host
    end
  end
end
