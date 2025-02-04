# test/lib/railsmaker/generators/mailjet_generator_test.rb

require 'test_helper'

class MailjetGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::MailjetGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_creates_gemfile_with_required_gems
    run_generator ['MyApp', 'no-reply@myapp.com', 'myapp.com']

    assert_file 'Gemfile' do |content|
      assert_match(/gem "mailjet", "~> 1\.8"/, content)
    end
  end

  def test_generator_creates_initializer
    run_generator ['MyApp', 'no-reply@myapp.com', 'myapp.com']

    assert_file 'config/initializers/mailjet.rb' do |content|
      assert_match(/Mailjet\.configure do \|config\|/, content)
      assert_match(/config\.api_key = Rails\.application\.credentials\.dig\(:mailjet, :api_key\)/, content)
      assert_match(/config\.secret_key = Rails\.application\.credentials\.dig\(:mailjet, :secret_key\)/, content)
      assert_match(/config\.default_from = Rails\.application\.credentials\.dig\(:app, :mailer_sender\)/, content)
      assert_match(/config\.api_version = "v3\.1"/, content)
    end
  end

  def test_generator_configures_mailer
    run_generator ['MyApp', 'no-reply@myapp.com', 'myapp.com']

    assert_file 'config/environments/production.rb' do |content|
      assert_match(/config\.action_mailer\.delivery_method = :mailjet_api/, content)
      assert_match(
        /config\.action_mailer\.default_url_options = \{ host: Rails\.application\.credentials\.dig\(:app, :host\) \}/, content
      )
    end

    assert_file 'app/mailers/application_mailer.rb' do |content|
      assert_match(/default from: Rails\.application\.credentials\.dig\(:app, :mailer_sender\)/, content)
    end
  end

  def test_generator_creates_git_commit
    assert_generator_git_commit('Add Mailjet configuration')

    run_generator ['MyApp', 'no-reply@myapp.com', 'myapp.com']
  end
end
