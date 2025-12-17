# ============================================================================
# DOCKERFILE - DigiDekan Backend (Production)
# ============================================================================
# Production-ready Python/Flask Backend mit Gunicorn
# ============================================================================

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first (better layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories for logs and uploads
RUN mkdir -p /var/log/digidekan /app/uploads && \
    chmod 755 /var/log/digidekan /app/uploads

# Environment variables
ENV FLASK_APP=run.py \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Start application with gunicorn using config file
CMD ["gunicorn", "--config", "gunicorn.conf.py", "run:app"]

# ============================================================================
# BUILD & RUN INSTRUCTIONS
# ============================================================================
# Build:
#   docker build -f docker/Dockerfile -t digidekan-backend:latest ./backend
#
# Run (standalone):
#   docker run -p 5000:5000 --env-file backend/.env.production digidekan-backend:latest
#
# Run (with docker-compose):
#   siehe docker-compose.production.yml
# ============================================================================
