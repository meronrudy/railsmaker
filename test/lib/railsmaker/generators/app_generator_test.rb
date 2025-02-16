# frozen_string_literal: true

require 'test_helper'

class AppGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper
  tests RailsMaker::Generators::AppGenerator

  destination File.expand_path('../../tmp', __dir__)

  def setup
    super
    # stub out the real `rails new`
    Rails::Generators::AppGenerator.stubs(:start).returns(true)

    RailsMaker::Generators::AppGenerator.any_instance
                                        .stubs(:current_dir)
                                        .returns(destination_root)
  end

  def teardown
    FileUtils.rm_rf(destination_root)
    super
  end

  def test_generates_app_successfully
    app_name = 'my_test_app'
    copy_test_fixtures(app_name)

    run_generator [
      '--name', app_name,
      '--docker', 'my_docker_user',
      '--ip', '192.168.0.99',
      '--domain', 'test.example.com'
    ]

    assert_file "#{app_name}/Gemfile"
    assert_file "#{app_name}/config/deploy.yml" do |content|
      assert_match(/my_docker_user/, content)
      assert_match(/192\.168\.0\.99/, content)
      assert_match(/test\.example\.com/, content)
      assert_match(/ssl: true\n\s+forward_headers: true/, content)
    end
  end

  def test_generates_app_successfully_with_skip_daisyui
    app_name = 'my_test_app_daisyui'
    copy_test_fixtures(app_name)

    run_generator [
      '--name', app_name,
      '--docker', 'my_docker_user',
      '--ip', '192.168.0.99',
      '--domain', 'test.example.com',
      '--skip-daisyui'
    ]

    assert_file "#{app_name}/Gemfile" do |content|
      assert_no_match(/daisyui/, content)
    end

    assert_file "#{app_name}/config/deploy.yml" do |content|
      assert_no_match(/daisyui/, content)
    end
  end

  def test_generates_app_with_custom_registry
    app_name = 'my_test_app'
    copy_test_fixtures(app_name)

    run_generator [
      '--name', app_name,
      '--docker', 'my_docker_user',
      '--ip', '192.168.0.99',
      '--domain', 'test.example.com',
      '--registry_url', 'registry.myapp.com'
    ]

    assert_file "#{app_name}/config/deploy.yml" do |content|
      assert_match(/server: registry\.myapp\.com/, content)
      assert_match(/username: my_docker_user/, content)
    end
  end
end
