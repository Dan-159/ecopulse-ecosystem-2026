from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# URL de la base de datos SQLite
DATABASE_URL = "sqlite:///./ecopulse.db"

# Motor de conexión
engine = create_engine(
    DATABASE_URL, connect_args={"check_same_thread": False}
)

# Sesiones
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para modelos
Base = declarative_base()

# Dependencia para usar en endpoints
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()