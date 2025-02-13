# frozen_string_literal: true

module RailsMaker
  module Generators
    class RegistryGenerator < ServerCommandGenerator
      source_root File.expand_path('templates/shell_scripts', __dir__)

      class_option :registry_host, type: :string, required: true,
                                   desc: 'Domain where Docker Registry will be hosted'
      class_option :registry_username, type: :string, required: true,
                                       desc: 'Username for registry authentication'
      class_option :registry_password, type: :string, required: true,
                                       desc: 'Password for registry authentication'

      def initialize(*args)
        super
        @registry_host = options[:registry_host]
        @registry_username = options[:registry_username]
        @registry_password = options[:registry_password]
      end

      private

      def script_name
        'registry'
      end

      def check_path
        '~/docker-registry'
      end

      def title
        "Installing Docker Registry on remote server #{options[:ssh_user]}@#{options[:ssh_host]}"
      end

      attr_reader :registry_host, :registry_username, :registry_password
    end
  end
end
