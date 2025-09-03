#!/bin/bash
set -euo pipefail

PROJECT_ID="jcw-2-android-estimator"
REGION="us-central1"
GITHUB_REPO="nathangonzalez/mainstreet_migrator"
SERVICE_NAME="main-street-migrator"
AR_REPO="main-street-migrator"
POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"
DEPLOYER_SA="manus-deployer"
RUNTIME_SA="msm-runtime"

# Enable services
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com --project=$PROJECT_ID

# Create Artifact Registry repo
gcloud artifacts repositories create $AR_REPO --repository-format=docker --location=$REGION --project=$PROJECT_ID

# Create SAs
gcloud iam service-accounts create $DEPLOYER_SA --description="Deployer SA for GitHub Actions" --project=$PROJECT_ID
gcloud iam service-accounts create $RUNTIME_SA --description="Runtime SA for Cloud Run" --project=$PROJECT_ID

# Grant roles to deployer SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$DEPLOYER_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/run.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$DEPLOYER_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/artifactregistry.writer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$DEPLOYER_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/cloudbuild.builds.editor"
gcloud iam service-accounts add-iam-policy-binding $RUNTIME_SA@$PROJECT_ID.iam.gserviceaccount.com --member="serviceAccount:$DEPLOYER_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"

# Grant roles to runtime SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$RUNTIME_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/artifactregistry.reader"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$RUNTIME_SA@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/secretmanager.secretAccessor"

# Create WIF pool and provider
gcloud iam workload-identity-pools create $POOL_NAME --location=global --project=$PROJECT_ID
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
  --location=global \
  --workload-identity-pool=$POOL_NAME \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition="attribute.repository=='$GITHUB_REPO' && attribute.ref=='refs/heads/main'" \
  --project=$PROJECT_ID

# Bind deployer SA to WIF
gcloud iam service-accounts add-iam-policy-binding $DEPLOYER_SA@$PROJECT_ID.iam.gserviceaccount.com \
  --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$POOL_NAME/*" \
  --role="roles/iam.workloadIdentityUser" \
  --project=$PROJECT_ID

echo "Setup complete. WIF provider: projects/$PROJECT_ID/locations/global/workloadIdentityPools/$POOL_NAME/providers/$PROVIDER_NAME"
