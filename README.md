[![Gem Version](https://img.shields.io/gem/v/railsmaker-core?color=blue&logo=rubygems)](https://rubygems.org/gems/railsmaker-core)
[![Support](https://img.shields.io/badge/Support-%F0%9F%8D%B8-yellow)](https://buymeacoffee.com/sgerov)
[![Live Demo](https://img.shields.io/badge/Live_Demo-Try_Now_-brightgreen?logo=rocket&color=00cc99)](https://railsmaker.com)
[![Live Demo Repo](https://img.shields.io/badge/Live_Demo_Repo-View_Code-blue?logo=github)](https://github.com/sgerov/railsmaker-sample)
[![Guide](https://img.shields.io/badge/Guide-10_Steps_To_Prod-orange?logo=book)](./10-STEPS-TO-PROD.md)

# 📦 Railsmaker

Ship your MVP in hours, not weeks • Zero config needed • Save $120+/month and 20+ dev hours

## ⚡ Why Railsmaker?
- **Ship Faster**: From zero to production in 15 minutes
- **Growth Ready**: Built-in analytics, SEO, and monitoring
- **Own Your Data**: Fully self-hosted, full control, full flexibility
- **Cost Efficient**: You decide how much you want to spend
- **DX Focused**: Modern stack, zero configuration

## ✨ Features

#### Growth & Analytics
- **Privacy-focused**: Self-hosted Plausible, Signoz, and Docker Registry
- **SEO**: Auto-optimized meta-tags & sitemaps
- **Performance**: Lightning-fast ~50ms page loads
- **Mobile First**: Instant responsive layouts

#### Developer Experience
- **UI**: Latest TailwindCSS 4 + DaisyUI 5
- **Auth**: Battle-tested Clearance + OmniAuth
- **Storage**: SQLite + Litestream
- **Email**: Production-ready Mailjet integration
- **Modern Stack**: Rails 8, Ruby 3.2, Hotwire magic

#### Infrastructure
- **Monitoring**: Full SigNoz & Sentry integration
- **Deploy**: One-command Kamal deployments, self-hosted Registry support
- **Observability**: Enterprise-grade OpenTelemetry + Lograge
- **Scale-ready**: Global CDN support, multi-environment

## 🚀 Setup

### Prerequisites
- Ruby 3.x (`rbenv` or `rvm` recommended)
- Bundler: `gem install bundler`
- Bun: [Install guide](https://bun.sh)
- Git
- Dev tools:
  - Ubuntu/Debian: `sudo apt install build-essential libyaml-dev`
  - macOS: `xcode-select --install`
- Docker (for analytics & monitoring)

### 1. Bootstrapping your app

#### A. Set Required Environment Variables

```bash
# Docker registry access (required)
export KAMAL_REGISTRY_PASSWORD="docker-registry-password"

# Litestream backup configuration (optional)
export LITESTREAM_ACCESS_KEY_ID="access-key"
export LITESTREAM_SECRET_ACCESS_KEY="secret-access-key"
export LITESTREAM_BUCKET="https://eu2.yourbucketendpoint.com/"
export LITESTREAM_REGION="eu2"
```

#### B. Install and Deploy

```bash
gem install railsmaker-core

# Interactive wizard (2 minutes)
railsmaker new:wizard

# Deploy to any cloud
kamal setup
```

If you have chosen to include litestream keep in mind that the corresponding kamal accessory will also be deployed.

### 2. Setting up Monitoring (Optional)

#### A. Install SigNoz Server
```bash
railsmaker remote signoz \
  --ssh-host=monitor.example.com \
  --ssh-user=deploy
```

#### B. Add OpenTelemetry Collector to apps server
```bash
railsmaker remote signoz:opentelemetry \
  --ssh-host=app.example.com \
  --ssh-user=deploy \
  --signoz-host=monitor.example.com \
  --hostname=my-production-apps
```

### 3. Setting up Analytics (Optional)
```bash
railsmaker remote plausible \
  --ssh-host=analytics.example.com \
  --ssh-user=deploy \
  --analytics-host=plausible.example.com
```

### 4. Setting up Private Docker Registry (Optional)
```bash
railsmaker remote registry \
  --ssh-host=192.168.1.10 \
  --ssh-user=deploy \
  --registry-host=registry.example.com \
  --registry-username=admin \
  --registry-password=secret
```

After setting up your registry:
1. Create an A record for `registry.example.com` pointing to your server
2. Update your Kamal config to use your private registry (unless you already used `-r` option):
```yaml
# config/deploy.yml
registry:
  server: registry.example.com
  username: admin
  password:
    - KAMAL_REGISTRY_PASSWORD
```

### Verification

- SigNoz Dashboard: `https://monitor.example.com:3301`
- Plausible Analytics: `https://analytics.example.com`
- Docker Registry: `https://registry.example.com`
- Your App: `https://app.example.com`

> **Note**: All services are tested on Ubuntu 24.04 and macOS 15.2.

**For a more detailed guide, check out [10 Steps To Prod](./10-STEPS-TO-PROD.md).**

### Environment Requirements

- **SigNoz Server**: 2 CPU, 4GB RAM minimum
- **Plausible**: 1 CPU, 2GB RAM minimum
- **App Server**: 1 CPU, 2GB RAM minimum

You can decide how to split the services between your servers (e.g. SigNoz & Plausible on a separate server from the app or apps).

### Database Recovery

In case of DB failure, follow these steps to recover your data:

1. Stop the application:
```bash
kamal app stop
```

2. Remove existing database files:
```bash
kamal app exec /bin/sh -i
rm -rf ./storage/*
exit
```

3. Recover files and set proper ownership to files:
```bash
kamal restore-db-app
kamal restore-db-cache
kamal restore-db-queue
kamal restore-db-cable
kamal restore-db-ownership
```

4. Restart Litestream to initiate recovery:
```bash
kamal accessory reboot litestream
```

5. Start the application:
```bash
kamal app boot
```

### Managing Docker Services

After deploying services with `railsmaker remote` commands, you can manage them using standard Docker commands:

```bash
# Navigate to the service directory
cd ~/SERVICE_DIRECTORY

# Common commands for all services
docker compose ps          # List containers
docker compose logs -f     # View logs
docker compose restart     # Restart all containers
docker compose down        # Stop all containers
docker compose up -d       # Start all containers
```

Service directories:
- Plausible Analytics: `~/plausible-ce`
- SigNoz Server: `~/signoz/deploy/docker`
- SigNoz Server Collector: `~/signoz/deploy/docker/generator/infra`
- OpenTelemetry Collector (other servers): `~/signoz-opentelemetry/deploy/docker/generator/infra`

> **Note**: Replace `~` with the absolute path if using sudo or running commands as another user.

### Cloudflare DNS

If you are relying on Cloudflare, make sure you set-up SSL/TLS to Full for your application and analytics.

## Support

This project is **pay-what-you-want**. If it helps you ship faster:

[![Support](https://img.shields.io/badge/Support-%F0%9F%8D%B8-yellow?style=for-the-badge)](https://buymeacoffee.com/sgerov)

*Give it a try at [railsmaker.com](https://railsmaker.com)*
