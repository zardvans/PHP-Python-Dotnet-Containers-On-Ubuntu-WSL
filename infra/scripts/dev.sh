#!/bin/bash

echo "🚀 Starting dev environment..."

cp infra/dotnet/Dockerfile-dev infra/dotnet/Dockerfile

cp podman-compose-dev.yml podman-compose.yml

podman-compose down --remove-orphans
podman volume prune -f
podman container prune -f
podman image prune -f
podman system prune -f
podman-compose up -d --build
echo "✅ Containers running"
echo "🌐 Laravel: http://localhost:8000"
echo "🌐 .NET: http://localhost:8001"

# podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" && for c in php python nginx dotnet; do echo "=== $c ==="; podman inspect "$c" --format '{{range .State.Health.Log}}{{.ExitCode}} {{.Output}}{{println}}{{end}}' 2>/dev/null || true; done