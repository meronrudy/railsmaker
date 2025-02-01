# Railsmaker

An opinionated Rails 8 application generator with modern defaults.

## Pre-requirements

- **Bun**: we can't rely on `rails/propshaft` because tailwindcss-rails doesn't work when using Apple Silicon emulation for amd64.
- **Rails 8**

## Installation

Install the gem locally:

```
gem build railsmaker.gemspec
gem install railsmaker-0.0.1.gem
```

## Usage

This gem provides Rails generators for creating new applications and installing additional components.

Sample installation:

```
# full app:
railsmaker app:full my-app johndoe 192.168.1.100 my-app.example.com analytics.example.com https://sentry.dsn

# light app:
railsmaker app:light my-app johndoe 192.168.1.100 my-app.example.com
```

Add secrets:

```
VISUAL="cursor --wait" bin/rails credentials:edit

secret_key_base: <secret
google_oauth:
  client_id: <client>
  client_secret: <client_secret>
sentry_dsn: <sentry_dsn>
```

And you are ready to go!

For further help:

```
railsmaker help

railsmaker help app

railsmaker help signoz
```

## License

MIT