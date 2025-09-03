from flask import Blueprint, request, jsonify, current_app
from ..models.user import User
from ..services.security_manager import issue_token, verify_token
from ..models import db

bp = Blueprint("auth", __name__)


@bp.route("/login", methods=["POST"])  # registered under /api/auth/login
def login():
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")
    if not username or not password:
        return jsonify({"error": "username and password required"}), 400

    user = User.query.filter_by(username=username).first()
    if not user or not user.check_password(password):
        return jsonify({"error": "invalid credentials"}), 401

    access_token = issue_token({"sub": user.id, "username": user.username})
    return jsonify({"tokens": {"access_token": access_token}, "user": user.to_dict()})


@bp.route("/refresh", methods=["POST"])
def refresh():
    # simple demo: re-issue a token if existing valid token provided
    data = request.get_json() or {}
    token = data.get("token")
    if not token:
        return jsonify({"error": "token required"}), 400
    payload = verify_token(token)
    if not payload:
        return jsonify({"error": "invalid token"}), 401
    new = issue_token({"sub": payload.get("sub"), "username": payload.get("username")})
    return jsonify({"tokens": {"access_token": new}})


@bp.route("/logout", methods=["POST"])
def logout():
    # demo: no server sessions stored
    return jsonify({"ok": True})


@bp.route("/profile", methods=["GET"])
def profile():
    auth = request.headers.get("Authorization", "")
    token = auth.replace("Bearer ", "") if auth.startswith("Bearer ") else None
    if not token:
        return jsonify({"error": "missing token"}), 401
    payload = verify_token(token)
    if not payload:
        return jsonify({"error": "invalid token"}), 401
    user = User.query.get(payload.get("sub"))
    if not user:
        return jsonify({"error": "user not found"}), 404
    return jsonify({"user": user.to_dict()})


@bp.route("/sessions", methods=["GET"])
def sessions():
    # demo: return empty sessions list
    return jsonify({"sessions": []})
