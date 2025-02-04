# frozen_string_literal: true

require 'opentelemetry/sdk'

OpenTelemetry::SDK.configure do |c|
  c.use_all
end

Rails.application.initialize! 