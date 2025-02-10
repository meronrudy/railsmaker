# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'railsmaker'
  s.version     = '0.0.1'
  s.executables = ['railsmaker']
  s.summary     = 'Rails 8 app generator with Tailwind, DaisyUI, and Kamal'
  s.authors     = ['Sava Gerov']
  s.email       = ['sava@gerov.es']
  s.files       = Dir['lib/**/*', 'exe/*', 'README.md']

  # Runtime dependencies
  s.add_runtime_dependency 'clearance', '2.9.3'
  s.add_runtime_dependency 'kamal', '2.5.2'
  s.add_runtime_dependency 'lograge', '0.14.0'
  s.add_runtime_dependency 'logstash-event', '1.2.02'
  s.add_runtime_dependency 'mailjet', '1.8'
  s.add_runtime_dependency 'omniauth', '2.1.2'
  s.add_runtime_dependency 'omniauth-google-oauth2', '1.2.1'
  s.add_runtime_dependency 'omniauth-rails_csrf_protection', '1.0.2'
  s.add_runtime_dependency 'opentelemetry-exporter-otlp', '0.29.1'
  s.add_runtime_dependency 'opentelemetry-instrumentation-all', '0.73.1'
  s.add_runtime_dependency 'opentelemetry-sdk', '1.7.0'
  s.add_runtime_dependency 'rails', '8.0.1'
  s.add_runtime_dependency 'sentry-rails', '5.22.4'
  s.add_runtime_dependency 'sentry-ruby', '5.22.4'
  s.add_runtime_dependency 'sitemap_generator', '6.3.0'
  s.add_runtime_dependency 'tailwindcss-rails', '4.0.0'
  s.add_runtime_dependency 'thor', '1.3.2'
  s.add_runtime_dependency 'tzinfo-data', '1.2025.1' # for stripped-down ubuntu installations

  s.license = 'MIT'
  s.required_ruby_version = '>= 3.2.0'
  s.homepage = 'https://github.com/sgerov/railsmaker'
end
