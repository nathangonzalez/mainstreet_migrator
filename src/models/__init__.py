from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()


def create_tables_and_seed():
    from .user import User

    db.create_all()

    # seed default admin user
    if not User.query.filter_by(username="admin").first():
        admin = User(username="admin", role_name="admin")
        admin.set_password("admin123")
        db.session.add(admin)
        db.session.commit()
