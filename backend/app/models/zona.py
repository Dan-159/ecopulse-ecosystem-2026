from sqlalchemy import Column, Integer, String
from backend.app.database import Base
from sqlalchemy.orm import relationship

class Zona(Base):
    __tablename__ = "zonas"
    
    id_zona = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    ubicacion = Column(String, nullable=False)
    
    # Relación: Una zona tiene muchos sensores
    sensores = relationship("Sensor", back_populates="zona", cascade="all, delete-orphan")