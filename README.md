# Main Street Migrator

A comprehensive platform for managing digital asset migration during acquisitions.

## Project Structure (Refactored)

- `/src` - Core application files
  - `main.py` - Main Flask application with API endpoints
  - `config.py` - Configuration settings
- `/static` - Static web files
  - `index.html` - Main frontend SPA
  - `app.css` - CSS styles
- `run.py` - Script to run the Flask application
- `start_app.bat` - Batch file to easily start the application
- `wsgi.py` - WSGI entry point for production servers
- `comprehensive_test_suite.py` - Comprehensive test suite for the application
- `test_comprehensive.py` - Implementation test script
- `test_app.py` - Unit tests for the application
- `/archive` - Archived files not currently in use
- `uat_server.ps1` - PowerShell script for User Acceptance Testing
- `start_uat.bat` - Batch file to start the UAT environment
- `uat_config.py` - Configuration for the UAT environment
- `www_access.bat` - Utility to expose UAT server to the internet

## UAT Environment

For User Acceptance Testing (UAT), we've set up a dedicated environment with mock data and API responses:

### Starting the UAT Environment

1. Run the UAT server:
   ```
   .\start_uat.bat
   ```

2. Access the application at http://localhost:8081

3. Login credentials:
   - Username: admin
   - Password: admin123

### Exposing UAT to the Internet (WWW)

To make the UAT environment accessible from the internet:

1. With the UAT server running, open a new terminal
2. Run the WWW access utility:
   ```
   .\www_access.bat
   ```
3. The utility will provide a temporary public URL that can be shared with testers

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
3. Run the application:
   ```
   python run.py
   ```
   
   Or simply double-click `start_app.bat` on Windows

4. Access the application at http://localhost:8080

## Running Tests

- Run the comprehensive test suite:
  ```
  python comprehensive_test_suite.py
  ```

- Run the implementation tests:
  ```
  python test_comprehensive.py
  ```

- Run unit tests:
  ```
  python test_app.py
  ```

## API Endpoints

- `/api/health` - Health check endpoint
- `/api/auth/login` - Authentication endpoint
- `/api/assets` - Asset management endpoints
- `/api/discovery/*` - Asset discovery endpoints
- `/api/migration/*` - Migration management endpoints
- `/api/compliance/*` - Compliance framework endpoints
- `/api/audit/*` - Audit verification endpoints
- `/api/target-systems/*` - Target system management endpoints
- `/api/user/*` - User settings endpoints

## Features

- JWT-based authentication
- Asset discovery and management
- Migration planning and execution
- Compliance verification
- Target system configuration
- User management

## Fast Public URL (Original Deployment Info)

Local run:

```bash
python -m venv .venv && . .venv/bin/activate   # Windows: .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt gunicorn
export PORT=8080 JWT_SECRET_KEY=change-me       # Windows PowerShell: $env:PORT="8080"
gunicorn -w 3 -b 0.0.0.0:$PORT src.main:app
```

Public tunnel (Cloudflare):

```bash
cloudflared tunnel --url http://localhost:8080
```

On Windows: `winget install Cloudflare.cloudflared` ; macOS: `brew install cloudflared`.

Hosted on Render (using `render.yaml`):

- Connect your GitHub repo to Render → "New +" → "Blueprint" → pick this repo.
- Render auto-detects `render.yaml`, sets env, deploys, and gives a public URL.
