# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry_dsn)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
end
