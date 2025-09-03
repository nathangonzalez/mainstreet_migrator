from flask import Blueprint, request, jsonify
from ..models.acquisition import Acquisition
from ..models import db

bp = Blueprint("acquisition", __name__)


@bp.route("/", methods=["GET"])  # GET /api/acquisitions/
def list_acquisitions():
    items = Acquisition.query.all()
    return jsonify([i.to_dict() for i in items])


@bp.route("/", methods=["POST"])  # POST /api/acquisitions/
def create_acquisition():
    data = request.get_json() or {}
    name = data.get("name")
    metadata = data.get("metadata")
    if not name:
        return jsonify({"error": "name required"}), 400
    a = Acquisition(name=name, metadata=metadata)
    db.session.add(a)
    db.session.commit()
    return jsonify(a.to_dict()), 201
