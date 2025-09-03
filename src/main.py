# src/main.py
import os
from flask import Flask

app = Flask(__name__)

@app.get("/api/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    # Only used locally; Cloud Run will use Gunicorn below
    port = int(os.environ.get("PORT", 5003))
    app.run(host="0.0.0.0", port=port)
