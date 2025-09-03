# syntax=docker/dockerfile:1
FROM python:3.11-slim

# Avoid interactive prompts, speed up pip
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# System deps (optional; uncomment if you need)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential curl && \
#     rm -rf /var/lib/apt/lists/*

# Install Python deps first (better caching)
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy app
COPY src ./src
# If you serve a built frontend, ensure it’s under ./src/static

# Cloud Run provides PORT; don’t hardcode
ENV PORT=5003

# Expose for local runs (not used by Cloud Run)
EXPOSE 5003

# Gunicorn: 2 workers, threads, bind to $PORT
# If your app is a module-level "app" in src/main.py:
CMD gunicorn -w 2 -k gthread -t 0 -b 0.0.0.0:$PORT src.main:app

# If you use an app factory "create_app", use:
# CMD ["gunicorn", "-w", "2", "-k", "gthread", "-t", "0", "-b", "0.0.0.0:${PORT}", "src.main:create_app()"]

