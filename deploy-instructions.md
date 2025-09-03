Main Street Migrator - Deploy Instructions

This repository contains a demo Flask app designed for local development and deployment to Cloud Run.

Build & Deploy (recommended):
1. Build the container image locally or in CI. Use a service account with Workload Identity Federation (WIF) to authenticate instead of JSON key files.

2. Set these environment variables for production:
   - FLASK_ENV=production
   - SECRET_KEY=(recommended: use a secure secret from your secrets manager)
   - DATABASE_URL (optional; if omitted the app will use sqlite at /tmp/app.db in container)
   - PORT (Cloud Run sets PORT to 8080 automatically)
   - OPENAI_API_KEY / OPENAI_API_BASE (optional)

3. Deploy to Cloud Run (gcloud example):
   gcloud run deploy main-street-migrator --image gcr.io/PROJECT_ID/main-street-migrator --platform managed --region us-central1 --allow-unauthenticated --set-env-vars SECRET_KEY=...,DATABASE_URL=...

Notes:
- This demo uses sqlite for simplicity. For production use a managed SQL database and set DATABASE_URL appropriately.
- Frontend: if you have a separate frontend project, copy its built `dist/` into `static/` or add it to the Docker build.
