# frozen_string_literal: true

require 'opentelemetry/sdk'

OpenTelemetry::SDK.configure(&:use_all)

Rails.application.initialize!
