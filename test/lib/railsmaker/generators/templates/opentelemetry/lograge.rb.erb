Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params].except("controller", "action")
    }
  end
end
