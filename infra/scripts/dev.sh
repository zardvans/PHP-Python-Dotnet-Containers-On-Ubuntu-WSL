#!/bin/bash

echo "🚀 Starting dev environment..."

cp podman-compose-dev.yml podman-compose.yml

podman-compose down
podman-compose up -d --build

echo "✅ Containers running"
echo "🌐 Laravel: http://localhost:8080"