import os
import secrets


class Config:
    FLASK_ENV = os.environ.get("FLASK_ENV", "production")
    # SECRET_KEY: prefer env, else generate
    SECRET_KEY = os.environ.get("SECRET_KEY") or secrets.token_urlsafe(32)

    OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
    OPENAI_API_BASE = os.environ.get("OPENAI_API_BASE")

    PORT = int(os.environ.get("PORT", 5003))

    # DATABASE_URL: allow override; support DB_URL as alternate name (used by CI scripts)
    if os.environ.get("DATABASE_URL"):
        DATABASE_URL = os.environ.get("DATABASE_URL")
    elif os.environ.get("DB_URL"):
        DATABASE_URL = os.environ.get("DB_URL")
    else:
        # if PORT is 8080 or running in GCP (K_SERVICE), prefer /tmp
        if os.environ.get("PORT") == "8080" or os.environ.get("K_SERVICE"):
            DATABASE_URL = "sqlite:////tmp/app.db"
        else:
            DATABASE_URL = "sqlite:///./database/app.db"

    SQLALCHEMY_DATABASE_URI = DATABASE_URL
    SQLALCHEMY_TRACK_MODIFICATIONS = False
