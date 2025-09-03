from . import db


class AuditTrail(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    action = db.Column(db.String(255))
    details = db.Column(db.Text)

    def to_dict(self):
        return {"id": self.id, "action": self.action, "details": self.details}
