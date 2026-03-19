# python/Dockerfile
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements first (good for caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY ../apps/python-service/. .

# Set environment variable
ENV PYTHONUNBUFFERED=1

# Start FastAPI with uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]