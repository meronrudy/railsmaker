# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'your-api'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
end
