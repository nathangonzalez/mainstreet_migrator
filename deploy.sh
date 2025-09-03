#!/usr/bin/env bash
set -euo pipefail

# === Config (edit or export before run) ===
: "${PROJECT_ID:=jcw-2-android-estimator}"
: "${REGION:=us-central1}"
: "${SERVICE_NAME:=main-street-migrator}"
: "${AR_REPO:=apps}"
: "${PORT:=8080}" # Cloud Run uses 8080; app binds to $PORT

need() { command -v "$1" >/dev/null || { echo "Missing $1"; exit 1; }; }
need gcloud
need bash

echo "🔧 Ensuring folders..."
mkdir -p database static

echo "🧭 gcloud project -> ${PROJECT_ID}"
gcloud config set project "${PROJECT_ID}" >/dev/null

echo "🔓 Enabling APIs..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com --quiet

echo "🏷️ Ensuring Artifact Registry: ${AR_REPO} (${REGION})"
gcloud artifacts repositories describe "${AR_REPO}" --location="${REGION}" >/dev/null 2>&1 \
 || gcloud artifacts repositories create "${AR_REPO}" --repository-format=docker --location="${REGION}" --description="App images"

# Optionally build frontend if present (local build)
if [ -d "main-street-migrator-frontend" ]; then
  echo "🧱 Building frontend..."
  (cd main-street-migrator-frontend && npm ci && npm run build)
  mkdir -p static
  cp -r main-street-migrator-frontend/dist/* static/ || true
fi

TAG="$(date +%Y%m%d%H%M%S)"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/${SERVICE_NAME}:${TAG}"

echo "🏗️ Build & push with Cloud Build..."
gcloud builds submit --tag "${IMAGE}" .

echo "🚀 Deploy to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE}" \
  --region "${REGION}" \
  --platform managed \
  --allow-unauthenticated \
  --port "${PORT}" \
  --set-env-vars SECRET_KEY=auto,FLASK_ENV=production,DB_URL=sqlite:////tmp/app.db \
  --quiet

URL="$(gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --format='value(status.url)')"
echo "🌐 URL: ${URL}"

echo "🩺 Health check..."
curl -fsS "${URL}/api/health" && echo "✅ Health OK" || { echo "❌ Health failed"; exit 1; }

echo "🔐 Test login..."
LOGIN="$((curl -fsS -X POST "${URL}/api/auth/login" -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin123"}') || true)"
echo "${LOGIN}" | head -c 400; echo
echo "🎉 Done."
