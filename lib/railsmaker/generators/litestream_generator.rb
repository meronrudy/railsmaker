module RailsMaker
  module Generators
    class LitestreamGenerator < BaseGenerator
      source_root File.expand_path('templates/litestream', __dir__)

      argument :app_name, desc: 'Application name for volume and bucket naming'
      argument :ip_address, desc: 'Server IP address'

      def create_litestream_config
        template 'litestream.yml.erb', 'config/litestream.yml'
      end

      def add_kamal_secrets
        inject_into_file '.kamal/secrets', after: "RAILS_MASTER_KEY=$(cat config/master.key)\n" do
          <<~YAML

# Litestream credentials for S3-compatible storage
LITESTREAM_ACCESS_KEY_ID=$LITESTREAM_ACCESS_KEY_ID
LITESTREAM_SECRET_ACCESS_KEY=$LITESTREAM_SECRET_ACCESS_KEY
LITESTREAM_BUCKET=$LITESTREAM_BUCKET
LITESTREAM_REGION=$LITESTREAM_REGION
LITESTREAM_BUCKET_NAME=#{app_name}
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
    host: #{ip_address}
    volumes:
      - "#{app_name.underscore}_storage:/rails/storage"
    files:
      - config/litestream.yml:/etc/litestream.yml
    cmd: replicate -config /etc/litestream.yml
    env:
      secret:
        - LITESTREAM_ACCESS_KEY_ID
        - LITESTREAM_SECRET_ACCESS_KEY
        - LITESTREAM_BUCKET
        - LITESTREAM_REGION
          YAML
        end

        inject_into_file 'config/deploy.yml', after: "bin/rails dbconsole\"\n" do
          <<-YAML
  restore-db-app: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production.sqlite3"
  restore-db-cache: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_cache.sqlite3"
  restore-db-queue: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_queue.sqlite3"
  restore-db-cable: accessory exec litestream "restore -if-replica-exists -config /etc/litestream.yml /rails/storage/production_cable.sqlite3"
  restore-db-ownership: server exec "sudo chown -R 1000:1000 /var/lib/docker/volumes/#{app_name.underscore}_storage/_data/"
          YAML
        end
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Litestream configuration')
      end
    end
  end
end
