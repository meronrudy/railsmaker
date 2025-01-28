# frozen_string_literal: true

module RailsMaker
  module Generators
    module GsubValidation
      def validate_gsub_strings(validations)
        validations.each do |validation|
          file_path = File.join(destination_root, validation.fetch(:file))

          unless File.exist?(file_path)
            raise "Required file not found: #{validation.fetch(:file)}. Maybe a dependency changed?"
          end

          content = File.read(file_path)
          validation.fetch(:patterns).each do |pattern|
            unless content.include?(pattern)
              raise "Expected to find '#{pattern}' in #{validation.fetch(:file)} but didn't. Maybe a dependency changed?"
            end
          end
        end
      end
    end
  end
end
