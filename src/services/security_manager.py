import time
import jwt
from flask import current_app


def issue_token(payload: dict, expires_in: int = 3600):
    secret = current_app.config.get("SECRET_KEY")
    data = payload.copy()
    data.update({"iat": int(time.time()), "exp": int(time.time()) + expires_in})
    return jwt.encode(data, secret, algorithm="HS256")


def verify_token(token: str):
    secret = current_app.config.get("SECRET_KEY")
    try:
        return jwt.decode(token, secret, algorithms=["HS256"])
    except Exception:
        return None


def require_auth(fn):
    from functools import wraps
    from flask import request, jsonify

    @wraps(fn)
    def wrapper(*args, **kwargs):
        auth = request.headers.get("Authorization", "")
        token = auth.replace("Bearer ", "") if auth.startswith("Bearer ") else None
        if not token:
            return jsonify({"error": "missing token"}), 401
        payload = verify_token(token)
        if not payload:
            return jsonify({"error": "invalid token"}), 401
        return fn(*args, **kwargs)

    return wrapper
