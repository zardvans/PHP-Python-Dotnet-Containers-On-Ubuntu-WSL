#!/bin/sh
set -e

echo "Waiting for PHP..."

# safer loop (no crash if nc missing)
while ! nc -z php 9000 2>/dev/null; do
  echo "PHP not ready..."
  sleep 2
done

echo "Waiting for Python..."
while ! curl -s http://python:5000 >/dev/null; do
  echo "Python not ready..."
  sleep 2
done

echo "Waiting for Dotnet..."
while ! curl -s http://dotnet:8080 >/dev/null; do
  echo "Dotnet not ready..."
  sleep 2
done

echo "All services are ready!"
exec nginx -g "daemon off;"