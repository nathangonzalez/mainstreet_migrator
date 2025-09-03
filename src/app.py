from flask import Flask, jsonify
from flask_cors import CORS
from .config import Config
from .models import db
import os
import sys


def create_app():
    app = Flask(__name__, static_folder="../static", static_url_path="/")
    app.config.from_object(Config)

    # warn if SECRET_KEY wasn't provided via env
    if not os.environ.get("SECRET_KEY"):
        print("WARNING: SECRET_KEY not provided via env; a generated key will be used.\nSet SECRET_KEY in production.", file=sys.stderr)

    CORS(app)

    db.init_app(app)

    with app.app_context():
        # create tables and seed default data
        try:
            from .models import create_tables_and_seed

            create_tables_and_seed()
        except Exception:
            # don't crash on startup if DB can't be created here; Cloud Run may mount differently
            pass

    # register routes
    from .routes import register_routes

    register_routes(app)

    @app.route("/api/health")
    def health():
        import time

        return jsonify(status="ok", security="demo", timestamp=int(time.time()))

    return app
