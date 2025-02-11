# 10 Steps To Prod

A guide for deploying a Rails application with observability, analytics, DaisyUI and much more using [RailsMaker](https://railsmaker.com).

## Table of Contents

1. [Introduction](#1-introduction)
2. [Pre-requisites](#2-pre-requisites)
3. [Setting Environment Variables](#3-setting-environment-variables)
4. [Remote Servers Setup](#4-remote-servers-setup)
   - [4.1. Install Docker & Add SSH Key](#41-install-docker--add-ssh-key)
   - [4.2. Metrics, tracing and logs (Signoz)](#42-metrics-tracing-and-logs-signoz)
   - [4.3. Analytics (Plausible)](#43-analytics-plausible)
5. [Generate the Rails app](#5-generate-the-rails-app)
6. [Add Rails Credentials](#6-add-rails-credentials)
7. [Deployment](#7-deployment)
8. [Add OpenTelemetry](#8-add-opentelemetry)
9. [DNS Configuration](#9-dns-configuration)
10. [Verification & Testing](#10-verification--testing)

## 1. Introduction

Welcome to the **RailsMaker** tutorial! In this guide, you’ll learn how to:

- Deploy a Rails app on two cloud servers (one for the Rails app, one for analytics/metrics).
- Integrate **analytics** (via Plausible) and **metrics/traces/logs** (via Signoz and OpenTelemetry).
- Configure DNS, environment variables, and secure secrets.
- Verify that everything is working end-to-end.

> **Goal**: By the end, you’ll have a live Rails app with observability tools in place, DB backups, and more.

## 2. Pre-requisites

Before diving into commands, ensure you have:

1. **RailsMaker** installed: `gem install railsmaker`
1. **A Domain Name**  
2. **2 Servers** (Ubuntu recommended):  
    - Server A for your Rails App (min 2GB RAM)  
    - Server B for Metrics/Analytics (min 4GB RAM)
3. *(Optional)* **S3 Bucket** for DB backups  
4. *(Optional)* Signed up for:  
    - **Google Cloud** (OAuth2 sign in)
    - **Sentry** (error tracking)
    - **Mailjet** (email service)
    - **Cloudflare** (DNS/CDN)
    - **OpsGenie** (alerts)

> **Note**: You can skip the optional services if you don’t need them

## 3. Setting Environment Variables

Next, you’ll need to **export** certain environment variables on your local machine (where you’ll run deployment commands).

Example (bash/zsh):

    export KAMAL_REGISTRY_PASSWORD="registry_password"
    
    # optional
    export LITESTREAM_ACCESS_KEY_ID="access_key_id"
    export LITESTREAM_SECRET_ACCESS_KEY="secret_access_key"
    export LITESTREAM_BUCKET="bucket_url"
    export LITESTREAM_REGION="region"

> Keep these credentials **private** and avoid committing them to git. The default setup uses ENV vars for simplicity but you can adjust your Kamal secrets file to use other methods.

## 4. Remote Servers Setup

Now, let’s prepare your servers. We’ll assume you have SSH access (user + password or existing SSH key) to each VPS.

### 4.1. Install Docker & Add SSH Key

1. **Install Docker** on each server:
    - Ubuntu example:

          curl -fsSL https://get.docker.com -o get-docker.sh
          sudo sh get-docker.sh

    - For other distros, see [Docker Docs](https://docs.docker.com/engine/install/).

2. **Add your SSH key** (for passwordless access):

        ssh-copy-id user@YOUR_SERVER_IP

   This ensures RailsMaker commands can run via SSH smoothly.

### 4.2. Metrics, tracing and logs (Signoz)

To set up **Signoz** (for observability) on your Metrics/Analytics server:

```bash
railsmaker remote signoz --ssh-host=METRICS_SERVER_IP
```

> ⏳ The Signoz query service will take a while to pull images and spin up, be patient

### 4.3. Analytics (Plausible)

For **Plausible Analytics** on the same or another server:

```bash
railsmaker remote plausible \
    --ssh-host=METRICS_SERVER_IP \
    --analytics-host=analytics.example.com
```

> Make sure `--analytics-host` is the domain/subdomain you plan to use for your analytics dashboard

## 5. Generate the Rails app

First, use `railsmaker` to generate the Rails app:

```bash
railsmaker new --name railsmaker-sample \
    --docker docker-username \
    --ip 12.123.123.1 \
    --domain example.com \
    --analytics analytics.example.com \
    --bucketname sample-railsmaker
```
> **Important**: You can skip integrations, see `railsmaker new --help` to see all available options and skip unwanted integrations

 Alternatively, you can use the wizard to enter the details interactively:

```bash
railsmaker new:wizard
```

The generator will create the app in the `--name` directory. It will execute bundler and migrations for you so we are ready to start the server:

**Start server locally**:

```bash
cd railsmaker-sample

./bin/dev
```

Visit `http://localhost:3000` to confirm your app works.

## 6. Add Rails Credentials

Ensure your **Rails credentials** (like `secret_key_base`) are properly set through the credentials.yml file:

```bash
EDITOR="vim" bin/rails credentials:edit
```

See the `credentials.example.yml` file for reference of all possible credentials.

> **Security Reminder**: Never commit your master key to a public repo.

## 7. Deployment

You’re almost there. Now run:

```bash
    kamal setup
```

- This may create or update necessary containers (including limestream if you have configured a S3 bucket). 
- If you get a timeout, simply re-run the command or check for connectivity issues.

## 8. Add OpenTelemetry

If you want distributed tracing and logs to be sent to your Signoz server:

```bash
railsmaker remote signoz:opentelemetry \
    --ssh-host=APP_SERVER_IP \
    --signoz-server-host=METRICS_SERVER_IP \
    --hostname=rails-apps
```

This configures your Rails app to send traces/spans/logs to Signoz through a sidecar container.

> Make sure APP_SERVER_IP is the IP of your Rails app server. This has to be run **only once** if you host several apps on the same server

## 9. DNS Configuration

1. Log into your DNS provider (e.g., Cloudflare or your registrar).  
2. Create **A records** pointing your domain (e.g. `myapp.com`) and subdomain (e.g. `analytics.myapp.com`) to the correct server IPs.  
3. If using Cloudflare’s proxy, ensure it's set to "Full".

## 10. Verification & Testing

1. **Visit Your App**  
   - In your browser, go to `https://myapp.com` (or your chosen domain).  
   - Confirm the Rails app is live.
2. **Check Analytics**  
   - Go to your Plausible dashboard (e.g., `https://analytics.myapp.com`).  
   - See if it’s tracking page views or real-time visitors.
3. **Review Metrics**  
   - Access Signoz at `http://METRICS_SERVER_IP:3301` (or your chosen domain).  
   - Check for application traces, metrics, or logs to ensure all data is flowing.

## Congrats!

You’ve deployed a Rails application with analytics and metrics using RailsMaker in just a few steps. 

Now you are ready to start bringing your ideas to life with a solid foundation!

This project is PWYW, if it helped you ship faster, consider:

[![Support](https://img.shields.io/badge/Support-%F0%9F%8D%B8-yellow?style=for-the-badge)](https://buymeacoffee.com/sgerov)

**Happy Deploying** 🚀