from . import db
import datetime


class MigrationJob(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    status = db.Column(db.String(64), default="pending")
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def to_dict(self):
        return {"id": self.id, "status": self.status, "created_at": self.created_at.isoformat()}
