# frozen_string_literal: true

module RailsMaker
  module Generators
    class PlausibleInstrumentationGenerator < BaseGenerator
      argument :app_domain, desc: 'Domain of your application (e.g., app.example.com)'
      argument :analytics_domain, desc: 'Domain where Plausible is hosted (e.g., analytics.example.com)'

      def add_plausible_script
        content = <<~HTML.indent(4)
          <%# Plausible Analytics %>
          <script defer data-domain="#{app_domain}" src="https://#{analytics_domain}/js/script.file-downloads.outbound-links.pageview-props.revenue.tagged-events.js"></script>
          <script>window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }</script>
        HTML

        gsub_file 'app/views/layouts/application.html.erb',
                  %r{<%# Plausible Analytics %>.*?</script>\s*<script>.*?</script>}m,
                  content.strip.to_s
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Plausible Analytics')
      end
    end
  end
end
