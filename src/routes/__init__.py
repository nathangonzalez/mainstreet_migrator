def register_routes(app):
    # import blueprints and register
    from .auth import bp as auth_bp
    from .acquisition import bp as acq_bp
    from .migration import bp as migration_bp
    from .discovery import bp as discovery_bp
    from .audit import bp as audit_bp

    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(acq_bp, url_prefix="/api/acquisitions")
    app.register_blueprint(migration_bp, url_prefix="/api/migration")
    app.register_blueprint(discovery_bp)
    app.register_blueprint(audit_bp, url_prefix="/api/audit")
