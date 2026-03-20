# PHP-Python-Dotnet-Containers-On-Ubuntu-WSL

## Description

This repository provides a starter layout for running PHP, Python, and .NET services in containers on Ubuntu WSL using Podman Compose.

The project separates application code from infrastructure so each service can be developed independently while sharing a common local container setup.

## Folder structure

```text
.
├── PHP-Python-Dotnet-Containers-On-Ubuntu-WSL.sln
├── README.md
├── apps/
│   ├── dotnet-services/
│   │   └── MyApp/
│   ├── php-services/
│   └── python-services/
└── infra/
    ├── podman-compose.yml
    ├── podman-compose-dev.yml
    ├── podman-compose-prod.yml
    ├── dotnet/
    ├── nginx/
    ├── php/
    ├── python/
    └── scripts/
```

### Main directories

- `apps/dotnet-services/MyApp`: ASP.NET Core sample service.
- `apps/php-services`: PHP application served through Nginx and PHP-FPM.
- `apps/python-services`: Python service container source.
- `infra`: container definitions, reverse proxy config, and helper scripts.

## Getting started

### Prerequisites

- Ubuntu on WSL
- Podman
- podman-compose

### Start the development environment

From the repository root, run:

```bash
cp infra/podman-compose-dev.yml infra/podman-compose.yml
cp infra/dotnet/Dockerfile-dev infra/dotnet/Dockerfile
cd infra
podman-compose up -d --build
```

This starts the PHP, Python, .NET, Nginx, MySQL, and Redis containers for local development.

## Access services in the browser

### PHP service

The PHP service is served by Nginx on port `8000`.

- Main endpoint: `http://localhost:8000/`
- Health check: `http://localhost:8000/health.php`

### .NET service

The .NET service is available in two ways:

- Direct container port: `http://localhost:8001/`
- Through Nginx reverse proxy: `http://localhost:8000/dotnet/`

Useful .NET endpoints:

- Health check: `http://localhost:8001/health`
- Health check through Nginx: `http://localhost:8000/dotnet/health`
- Sample API: `http://localhost:8001/weatherforecast`
- Sample API through Nginx: `http://localhost:8000/dotnet/weatherforecast`
