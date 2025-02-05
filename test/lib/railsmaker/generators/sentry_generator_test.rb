# frozen_string_literal: true

require 'test_helper'

class SentryGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::SentryGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_configures_sentry
    run_generator
    assert_file 'Gemfile' do |content|
      assert_match(/gem "sentry-ruby", "~> 5\.22\.3"/, content)
      assert_match(/gem "sentry-rails", "~> 5\.22\.3"/, content)
    end
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add Sentry')
    run_generator
  end

  def test_generator_creates_sentry_initializer_correctly
    run_generator
    assert_file 'config/initializers/sentry.rb' do |content|
      assert_match(/Sentry\.init do \|config\|/, content)
      assert_match(/config\.dsn = Rails\.application\.credentials\.dig\(:sentry_dsn\)/, content)
      assert_match(/config\.breadcrumbs_logger = \[ :active_support_logger, :http_logger \]/, content)
    end
  end
end
