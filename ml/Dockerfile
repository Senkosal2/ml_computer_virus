# syntax=docker/dockerfile:1.6
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Copy only requirements first to maximize cache reuse
COPY requirements.txt /app/requirements.txt

# Use BuildKit cache for pip downloads/wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the project AFTER deps
COPY . /app

EXPOSE 8000
CMD ["bash", "-lc", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
