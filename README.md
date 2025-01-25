# Railsmaker

An opinionated Rails 8 application generator with modern defaults.

## Pre-requirements

- **Bun**: can't rely on `rails/propshaft` because tailwindcss doesn't work with the client when simulating an Apple Silicon amd64 machine
- **Rails 8**

## Installation

Install the gem locally:

```
gem build railsmaker.gemspec
gem install railsmaker-0.0.1.gem
```

## Usage

```
railsmaker g <app_name> <docker_username> <ip_address> <hostname>
```

Variables:

- `app_name`: the name of the app
- `docker_username`: the username of the Docker user
- `ip_address`: the IP address of the server
- `hostname`: the hostname of the server

Sample run:

```
railsmaker generate test-app savayg 192.168.1.100 test-app.domain.com
```

It will generate a new Rails app in the `test-app` directory and configure it with Tailwind, DaisyUI, and Kamal. Ready to be deployed to the IP address `192.168.1.100` and accessible at `https://test-app.domain.com` (assuming DNS has been set up by hand).

## License

MIT
