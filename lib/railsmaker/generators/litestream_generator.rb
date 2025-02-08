# frozen_string_literal: true

module RailsMaker
  module Generators
    class LitestreamGenerator < BaseGenerator
      source_root File.expand_path('templates/litestream', __dir__)

      class_option :bucketname, type: :string, required: true, desc: 'Litestream bucketname'
      class_option :name, type: :string, required: true, desc: 'Application name for volume and bucket naming'
      class_option :ip, type: :string, required: true, desc: 'Server IP address'

      def check_required_env_vars
        super(%w[
          LITESTREAM_ACCESS_KEY_ID
          LITESTREAM_SECRET_ACCESS_KEY
          LITESTREAM_ENDPOINT
          LITESTREAM_REGION
        ])
      end

      def create_litestream_config
        template 'litestream.yml.erb', 'config/litestream.yml'
      end

      def add_kamal_secrets
        inject_into_file '.kamal/secrets', after: "RAILS_MASTER_KEY=$(cat config/master.key)\n" do
          <<~YAML

            # Litestream credentials for S3-compatible storage
            LITESTREAM_ACCESS_KEY_ID=$LITESTREAM_ACCESS_KEY_ID
            LITESTREAM_SECRET_ACCESS_KEY=$LITESTREAM_SECRET_ACCESS_KEY
            LITESTREAM_ENDPOINT=$LITESTREAM_ENDPOINT
            LITESTREAM_REGION=$LITESTREAM_REGION
            LITESTREAM_BUCKET_NAME=#{options[:bucketname]}
          YAML
        end
      end

      def add_to_deployment
        validations = [
          {
            file: 'config/deploy.yml',
            patterns: ["bin/rails dbconsole\"\n", "arch: amd64\n"]
          }
        ]

        validate_gsub_strings(validations)

        inject_into_file 'config/deploy.yml', after: "arch: amd64\n" do
          <<~YAML

            accessories:
              litestream:
                image: litestream/litestream:0.3
                host: #{options[:ip]}
                volumes:
                  - "#{options[:name].underscore}_storage:/rails/storage"
                files:
                  - config/litestream.yml:/etc/litestream.yml
                cmd: replicate -config /etc/litestream.yml
                env:
                  secret:
                    - LITESTREAM_ACCESS_KEY_ID
                    - LITESTREAM_SECRET_ACCESS_KEY
                    - LITESTREAM_ENDPOINT
                    - LITESTREAM_REGION
                    - LITESTREAM_BUCKET_NAME
          YAML
        end

        inject_into_file 'config/deploy.yml', after: "bin/rails dbconsole\"\n" do
          <<-YAML
  restore-db-app: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production.sqlite3"
  restore-db-cache: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_cache.sqlite3"
  restore-db-queue: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_queue.sqlite3"
  restore-db-cable: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_cable.sqlite3"
  restore-db-ownership: server exec "sudo chown -R 1000:1000 /var/lib/docker/volumes/#{options[:name].underscore}_storage/_data/"
          YAML
        end
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Litestream configuration')

        say 'Successfully added Litestream configuration', :green
      end
    end
  end
end
