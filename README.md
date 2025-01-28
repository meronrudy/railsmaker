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

Sample usage:

```
railsmaker app my-app johndoe 192.168.1.100 my-app.example.com
```

For further help:

```
railsmaker help

railsmaker help app

railsmaker help signoz
```

## License

MIT