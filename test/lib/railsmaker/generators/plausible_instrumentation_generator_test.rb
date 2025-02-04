# frozen_string_literal: true

require 'test_helper'

class PlausibleInstrumentationGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::PlausibleInstrumentationGenerator
  destination File.expand_path('../../tmp', __dir__)

  def setup
    super
    @app_domain = 'myapp.com'
    @analytics_domain = 'analytics.myapp.com'
  end

  def teardown
    FileUtils.rm_rf(destination_root)
  end

  def test_generator_adds_plausible_script_to_layout
    run_generator [@app_domain, @analytics_domain]

    expected_script = <<~HTML.indent(4)
      <%# Plausible Analytics %>
      <script defer data-domain="#{@app_domain}" src="https://#{@analytics_domain}/js/script.file-downloads.outbound-links.pageview-props.revenue.tagged-events.js"></script>
      <script>window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }</script>
    HTML

    assert_file 'app/views/layouts/application.html.erb' do |content|
      assert_match expected_script.strip, content
    end
  end
end
