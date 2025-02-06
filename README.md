[![Gem Version](https://img.shields.io/gem/v/railsmaker?color=blue&logo=rubygems)](https://rubygems.org/gems/railsmaker)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

# 💎 Railsmaker 
[![Live Demo](https://img.shields.io/badge/Live_Demo-Try_Now_-brightgreen?style=for-the-badge&logo=rocket&color=00cc99)](https://railsmaker.com) [![Support](https://img.shields.io/badge/Support-%F0%9F%8D%B8-yellow?style=for-the-badge)](https://buymeacoffee.com/sgerov)

🔋 Turbocharged Rails 8 Starter Kit

*Batteries included • Zero to production in 5 minutes • PWYW*

✨ **Key Features**  
- 💅 **UI**: TailwindCSS 4 + DaisyUI  
- 🔐 **Auth**: Clearance + OmniAuth
- 📊 **Monitoring**: SigNoz & Sentry integration  
- 📈 **Analytics**: Self-hosted Plausible integration 
- 📨 **Email**: Mailjet integration
- 🚢 **Deploy**: Self-hosted anywhere, low maintenance
- 💾 **Backups**: S3-compatible with Litestream backups  

## ⚡ 60-Second Setup

0. **Prerequisites**:

- Ruby 3.x (`rbenv` or `rvm` recommended)
- Bundler: `gem install bundler`
- Bun: [Install guide](https://bun.sh)
- Git
- Dev tools:
  - Ubuntu/Debian: `sudo apt install build-essential libyaml-dev`
  - macOS: `xcode-select --install`

> Tested on Ubuntu 22.04 and macOS 15.2.

1. **Install & Create Project**:
```bash
gem install railsmaker

# Interactive wizard
railsmaker new --wizard

# or CLI:
railsmaker new --name YOUR_APP_NAME \
              --docker YOUR_DOCKER_ACCOUNT \
              --ip YOUR_SERVER_IP \
              --domain YOUR_DOMAIN \
              --analytics YOUR_ANALYTICS_DOMAIN \
              --bucketname YOUR_S3_BUCKET
```

2. **Configure Secrets**:
```bash
# Use sample credentials from config/credentials.example.yml

EDITOR="vim" bin/rails credentials:edit
```

3. **Add ENV variables**:
```bash
# Kamal Registry
export KAMAL_REGISTRY_PASSWORD="your-registry-pw"

# Litestream Backups (S3-compatible)
export LITESTREAM_ACCESS_KEY_ID="AKIA..."
export LITESTREAM_SECRET_ACCESS_KEY="..."
export LITESTREAM_BUCKET="your-bucket"
export LITESTREAM_REGION="eu2"
```

4. **Deploy to Production**:
```bash
kamal setup
```

## 🚀 Production-Ready for quick iteration

Quick iteration, zero-downtime deployments, and a modern stack that just works.

### 🛠️ **Infrastructure**
- ✅ **Auto-Backups**: Litestream → S3  
- 📊 **Monitoring**: SigNoz & Sentry  
- 🚢 **CI/CD**: Kamal deployments  
- 🌐 **Multi-Env**: Dev/Staging/Prod  
- 🔍 **Tracing**: OpenTelemetry  
- 📜 **Logging**: Lograge structured

### ⚡ **Developer Experience**
- 🎨 **UI Kit**: Tailwind + DaisyUI  
- 🔐 **Auth**: Clearance + OmniAuth  
- 📈 **SEO**: Auto-sitemaps  
- 📦 **Storage**: S3 + Litestream  
- 📨 **Email**: Postmark templates  
- 🛠️ **Zero-Config**: Batteries included

### 🌟 **Modern Stack**
- ✨ **Rails 8**: Ruby 3.2  
- ⚡ **Turbo/Hotwire**: Fast SPAs  
- 🔒 **Security**: CSRF protection  
- 📊 **Analytics**: Plausible.io  
- 🗃️ **Database**: SQLite scale-ready  
- 🧩 **Components**: ViewComponent

## 📈 PWYW model

This project is **pay-what-you-want** - if it saves you time, consider:  

[![Support](https://img.shields.io/badge/Support-%F0%9F%8D%B8-yellow?style=for-the-badge)](https://buymeacoffee.com/sgerov)

*Railsmaker is MIT licensed. Made with ❤️ by developers for developers.*
*Live demo available at [railsmaker.com](https://railsmaker.com)*