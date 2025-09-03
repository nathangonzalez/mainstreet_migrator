from flask import Blueprint, jsonify, request
from ..services.migration_engine import get_mappings
from ..models.migration_job import MigrationJob
from ..models import db

bp = Blueprint("migration", __name__)


@bp.route("/mappings", methods=["GET"])
def mappings():
    system_mappings, supported_formats = get_mappings()
    return jsonify({"system_mappings": system_mappings, "supported_formats": supported_formats})


@bp.route("/jobs", methods=["GET", "POST"])
def jobs():
    if request.method == "GET":
        jobs = MigrationJob.query.all()
        return jsonify([j.to_dict() for j in jobs])
    else:
        m = MigrationJob()
        db.session.add(m)
        db.session.commit()
        return jsonify(m.to_dict()), 201


@bp.route("/start/<int:job_id>", methods=["POST"])
def start_job(job_id):
    # placeholder for starting a job
    job = MigrationJob.query.get(job_id)
    if not job:
        return jsonify({"error": "not found"}), 404
    job.status = "running"
    db.session.commit()
    return jsonify(job.to_dict())
