# frozen_string_literal: true

Clearance.configure do |config|
  config.mailer_sender = Rails.application.credentials.dig(:app, :mailer_sender)
end
