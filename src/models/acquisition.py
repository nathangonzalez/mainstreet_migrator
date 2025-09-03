from . import db


class Acquisition(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    metadata = db.Column(db.Text)

    def to_dict(self):
        return {"id": self.id, "name": self.name, "metadata": self.metadata}
