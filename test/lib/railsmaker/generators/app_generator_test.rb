# test/generators/rails_maker/app_generator_test.rb
# frozen_string_literal: true

require 'test_helper'

class AppGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::AppGenerator
  destination File.expand_path('../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
    super
  end

  def setup
    super

    Rails::Generators::AppGenerator.stubs(:start).returns(true)
  end

  def test_generates_app_successfully
    assert_generator_git_commit 'Initial railsmaker commit'

    run_generator %w[
      my_test_app
      my_docker_user
      192.168.0.99
      test.example.com
    ]

    assert_file 'Gemfile'
    assert_file 'config/deploy.yml'
    assert_file 'config/credentials.example.yml'
    assert_file 'app/views/main/index.html.erb'

    assert_file 'config/deploy.yml' do |content|
      assert_match(/my_docker_user/, content)
      assert_match(/192\.168\.0\.99/, content)
      assert_match(/test\.example\.com/, content)
      assert_match(/ssl: true\n\s+forward_headers: true/, content)
    end

    assert_file 'app/views/layouts/application.html.erb' do |content|
      assert_match(/<html data-theme="cupcake">/, content)
      refute_match(/<main class="container mx-auto mt-28 px-5 flex">/, content)
    end
  end
end
