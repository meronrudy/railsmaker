# frozen_string_literal: true

require 'test_helper'

class OpentelemetryGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::OpentelemetryGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_creates_gemfile_with_required_gems
    run_generator %w[my-service]
    assert_file 'Gemfile' do |content|
      assert_match(/gem "opentelemetry-sdk", "~> 1.6.0"/, content)
      assert_match(/gem "opentelemetry-exporter-otlp", "~> 0.29.1"/, content)
      assert_match(/gem "opentelemetry-instrumentation-all", "~> 0.72.0"/, content)
      assert_match(/gem "lograge", "~> 0.14.0"/, content)
      assert_match(/gem "logstash-event", "~> 1.2.02"/, content)
    end
  end

  def test_generator_configures_opentelemetry_in_environment
    run_generator %w[my-service]
    assert_file 'config/environment.rb' do |content|
      assert_match(%r{require 'opentelemetry/sdk'}, content)
      assert_match(/OpenTelemetry::SDK.configure do \|c\|/, content)
      assert_match(/c.use_all/, content)
    end
  end

  def test_generator_creates_lograge_config
    run_generator %w[my-service]
    assert_file 'config/initializers/lograge.rb'
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add OpenTelemetry')

    run_generator %w[my-service]
  end
end
