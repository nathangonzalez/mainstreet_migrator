from . import db
import bcrypt


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(128), unique=True, nullable=False)
    password_hash = db.Column(db.LargeBinary(128), nullable=False)
    role_name = db.Column(db.String(64), default="user")
    permissions = db.Column(db.Text, default="[]")

    def set_password(self, password: str):
        self.password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())

    def check_password(self, password: str) -> bool:
        try:
            return bcrypt.checkpw(password.encode("utf-8"), self.password_hash)
        except Exception:
            return False

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "role_name": self.role_name,
            "permissions": [],
        }
