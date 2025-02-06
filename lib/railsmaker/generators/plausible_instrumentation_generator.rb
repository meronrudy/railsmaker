# frozen_string_literal: true

module RailsMaker
  module Generators
    class PlausibleInstrumentationGenerator < BaseGenerator
      class_option :domain, type: :string, required: true, desc: 'Domain of your application'
      class_option :analytics, type: :string, required: true, desc: 'Domain where Plausible is hosted'

      def add_plausible_script
        content = <<~HTML.indent(4)
          <%# Plausible Analytics %>
          <script defer data-domain="#{options[:domain]}" src="https://#{options[:analytics]}/js/script.file-downloads.outbound-links.pageview-props.revenue.tagged-events.js"></script>
          <script>window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }</script>
        HTML

        gsub_file 'app/views/layouts/application.html.erb',
                  %r{<%# Plausible Analytics %>.*?</script>\s*<script>.*?</script>}m,
                  content.strip.to_s
      end

      def git_commit
        git add: '.', commit: %(-m 'Add Plausible Analytics')

        say 'Successfully added Plausible Analytics', :green
      end
    end
  end
end
