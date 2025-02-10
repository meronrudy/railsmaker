SitemapGenerator::Sitemap.default_host = "https://#{Rails.application.credentials.dig(:app, :host)}"

SitemapGenerator::Sitemap.create do
  # Home page with high priority and frequent updates
  add root_path,
      changefreq: 'daily',
      priority: 1.0,
      lastmod: Time.current

  # Main feature pages
  add demo_path,
      changefreq: 'weekly',
      priority: 0.9,
      lastmod: Time.current
  add analytics_path,
      changefreq: 'weekly',
      priority: 0.8,
      lastmod: Time.current
  add support_path,
      changefreq: 'weekly',
      priority: 0.8,
      lastmod: Time.current

  # Legal pages with lower update frequency
  add privacy_path,
      changefreq: 'monthly',
      priority: 0.6,
      lastmod: Time.current
  add terms_path,
      changefreq: 'monthly',
      priority: 0.6,
      lastmod: Time.current
end
