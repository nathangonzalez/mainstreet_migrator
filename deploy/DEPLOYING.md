# Deploying Main Street Migrator to Cloud Run

## Overview
This document explains how to deploy the Main Street Migrator app to Google Cloud Run using GitHub Actions with Workload Identity Federation (WIF). The CI/CD pipeline builds a Docker image, pushes it to Artifact Registry, and deploys to Cloud Run.

## Prerequisites
- Google Cloud Project with billing enabled.
- GitHub repository with the app code.
- Workload Identity Federation set up (see IAM checklist below).
- Artifact Registry repository created in your GCP region.

## Required Repository Variables
Set these as GitHub Actions Repository Variables (Settings > Secrets and variables > Actions > Variables):
- `GCP_PROJECT_ID`: Your GCP project ID (e.g., my-project-123).
- `GCP_REGION`: GCP region (e.g., us-central1).
- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Full resource name of the WIF provider (e.g., projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider).
- `GCP_SERVICE_ACCOUNT`: Service account email for GitHub Actions (e.g., github-actions@my-project-123.iam.gserviceaccount.com).
- `AR_REPO`: Artifact Registry repository name (default: main-street-migrator).
- `SERVICE_NAME`: Cloud Run service name (default: main-street-migrator).

## Secrets in GCP Secret Manager
For runtime secrets like OPENAI_API_KEY:
1. Create the secret in GCP Secret Manager: `gcloud secrets create OPENAI_API_KEY --data-file=- <<< "your-key"`.
2. The workflow references it via `--set-secrets OPENAI_API_KEY=OPENAI_API_KEY:latest`.

## How CI/CD Works
1. On push to `main` or manual dispatch, the workflow runs.
2. Authenticates using WIF (no JSON keys).
3. Builds the Docker image and pushes to Artifact Registry.
4. Deploys to Cloud Run with specified configuration.
5. Runs a smoke test on `/api/health`.
6. Stores the image digest for rollback.

## Smoke-Test Commands
After deployment, test the service:
```bash
# Get the service URL
gcloud run services describe main-street-migrator --region us-central1 --format='value(status.url)'

# Test health endpoint
curl -f https://<service-url>/api/health

# Expected response: {"status": "ok", "security": "demo", "timestamp": <number>}
```

## Rollback Steps
1. Go to GitHub Actions > Deploy to Cloud Run > Run workflow.
2. Provide the image digest (from previous run's artifact or logs).
3. The rollback job will redeploy the specified digest.

## IAM Checklist
Ensure the following IAM roles are granted:
- `github-actions@<PROJECT_ID>.iam.gserviceaccount.com`:
  - `roles/run.admin`
  - `roles/artifactregistry.writer`
  - `roles/iam.serviceAccountUser` (on `msm-runtime@<PROJECT_ID>.iam.gserviceaccount.com`)
- `msm-runtime@<PROJECT_ID>.iam.gserviceaccount.com`:
  - `roles/secretmanager.secretAccessor` (if using secrets)
- Artifact Registry repo exists: `gcloud artifacts repositories create main-street-migrator --repository-format=docker --location=us-central1`
- WIF provider is bound to the service account and restricted to this repo/branch.

## Cloud Logging
View logs: `gcloud logs tail --service main-street-migrator --region us-central1`

## Local Development
Use `docker-compose.yml` for local testing:
```bash
docker-compose up --build
# Access at http://localhost:5003/api/health
```
