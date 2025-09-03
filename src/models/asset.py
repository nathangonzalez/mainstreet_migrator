from . import db


class Asset(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    acquisition_id = db.Column(db.Integer, nullable=False)
    path = db.Column(db.String(1024))

    def to_dict(self):
        return {"id": self.id, "acquisition_id": self.acquisition_id, "path": self.path}
