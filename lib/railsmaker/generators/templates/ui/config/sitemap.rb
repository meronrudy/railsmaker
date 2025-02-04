# frozen_string_literal: true

SitemapGenerator::Sitemap.default_host = "https://#{Rails.application.credentials.dig(:app, :host)}"

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: 'weekly', priority: 1.0
  add demo_path, changefreq: 'weekly', priority: 0.9
  add analytics_path, changefreq: 'weekly', priority: 0.8
  add support_path, changefreq: 'weekly', priority: 0.8
  add privacy_path, changefreq: 'monthly', priority: 0.6
  add terms_path, changefreq: 'monthly', priority: 0.6
end
