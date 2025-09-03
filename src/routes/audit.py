from flask import Blueprint, request, jsonify

bp = Blueprint("audit", __name__)


@bp.route("/compliance-frameworks", methods=["GET"])
def compliance_frameworks():
    # demo list
    return jsonify({"frameworks": ["SOC2", "ISO27001", "HIPAA"]})


@bp.route("/verification/<int:acq_id>", methods=["POST"])
def verification(acq_id):
    # placeholder verification
    return jsonify({"acquisition_id": acq_id, "verification": "queued"}), 202


@bp.route("/compliance-dashboard/<int:acq_id>", methods=["GET"])
def compliance_dashboard(acq_id):
    return jsonify({"acquisition_id": acq_id, "status": "ok"})
