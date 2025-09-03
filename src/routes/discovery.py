from flask import Blueprint, request, jsonify

bp = Blueprint("discovery", __name__)


def _classify_payload(payload):
    # stub classifier: echo
    return {"classification": "demo", "input": payload}


@bp.route("/api/discovery/classify", methods=["POST"])  # primary
@bp.route("/api/assets/classify", methods=["POST"])  # alias
def classify():
    data = request.get_json() or {}
    result = _classify_payload(data)
    return jsonify(result)


@bp.route("/api/discovery/statistics/<int:acquisition_id>", methods=["GET"])  # primary
@bp.route("/api/assets/statistics/<int:acquisition_id>", methods=["GET"])  # alias
def statistics(acquisition_id):
    # stub statistics
    return jsonify({"acquisition_id": acquisition_id, "total_assets": 0, "classified": 0})
