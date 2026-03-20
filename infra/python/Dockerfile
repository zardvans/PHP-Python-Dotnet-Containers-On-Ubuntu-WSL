# python/Dockerfile
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements first (good for caching)
COPY infra/python/requirements.txt .

# Install dependencies
RUN (command -v apk >/dev/null && apk add --no-cache curl) || (apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*)
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY ../apps/python-services/. .

# Set environment variable
ENV PYTHONUNBUFFERED=1

# Start FastAPI with uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]