require 'test_helper'

class LitestreamGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::LitestreamGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_creates_litestream_config
    run_generator ['--bucketname=MyApp', '--name=MyApp', '--ip=192.168.1.1']

    assert_file 'config/litestream.yml' do |content|
      assert_match(/access-key-id: \${LITESTREAM_ACCESS_KEY_ID}/, content)
      assert_match(/secret-access-key: \${LITESTREAM_SECRET_ACCESS_KEY}/, content)
      assert_match(/endpoint: \${LITESTREAM_BUCKET}/, content)
      assert_match(/region: \${LITESTREAM_REGION}/, content)
    end
  end

  def test_generator_adds_kamal_secrets
    run_generator ['--bucketname=MyApp', '--name=MyApp', '--ip=192.168.1.1']

    assert_file '.kamal/secrets' do |content|
      assert_match(/LITESTREAM_ACCESS_KEY_ID=/, content)
      assert_match(/LITESTREAM_SECRET_ACCESS_KEY=/, content)
      assert_match(/LITESTREAM_BUCKET=/, content)
      assert_match(/LITESTREAM_REGION=/, content)
      assert_match(/LITESTREAM_BUCKET_NAME=MyApp/, content)
    end
  end

  def test_generator_adds_deployment_config
    run_generator ['--bucketname=MyApp', '--name=MyApp', '--ip=192.168.1.1']

    assert_file 'config/deploy.yml' do |content|
      assert_match(/accessories:/, content)
      assert_match(/litestream:/, content)
      assert_match(%r{image: litestream/litestream:0\.3}, content)
      assert_match(/host: 192\.168\.1\.1/, content)
      assert_match(/volumes:/, content)
      assert_match(/production\.sqlite3/, content)
    end
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add Litestream configuration')
    run_generator ['--bucketname=MyApp', '--name=MyApp', '--ip=192.168.1.1']
  end
end
