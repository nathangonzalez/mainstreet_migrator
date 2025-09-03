Main Street Migrator (demo)

See deploy-instructions.md for deployment notes. Run `pip install -r requirements.txt` and `python src/main.py` to start locally on port 5003.

## Deploy to Cloud Run
Push to main branch to trigger CI/CD via GitHub Actions + OIDC. See .github/workflows/deploy.yml and GCP setup script for details.

## How to Deploy
See `deploy/DEPLOYING.md` for detailed CI/CD setup, required variables, and deployment steps using GitHub Actions + WIF.
