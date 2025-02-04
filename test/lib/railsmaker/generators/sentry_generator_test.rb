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
    assert_file 'Gemfile', /gem "sentry-ruby"/
    assert_file 'Gemfile', /gem "sentry-rails"/
    assert_file 'config/initializers/sentry.rb'
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add Sentry')

    run_generator
  end
end
