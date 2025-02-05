# frozen_string_literal: true

require 'test_helper'

class AppFullGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::AppFullGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_creates_full_application
    RailsMaker::Generators::AppGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::OpentelemetryGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::SentryGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::AuthGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::UiGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::PlausibleInstrumentationGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::MailjetGenerator.any_instance.expects(:invoke_all)
    RailsMaker::Generators::LitestreamGenerator.any_instance.expects(:invoke_all)

    run_generator %w[the-app username 192.168.1.1 myapp.com analytics.myapp.com Company test@example.com]

    assert_directory 'the-app'
  end
end
