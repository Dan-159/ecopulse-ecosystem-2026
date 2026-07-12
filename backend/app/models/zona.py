from sqlalchemy import Column, Integer, String
from backend.app.database import Base
from sqlalchemy.orm import relationship

class Zona(Base):
    __tablename__ = "zonas"
    
    # Datos para identificar la zona
    id_zona = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    ubicacion = Column(String, nullable=False)
    
    # Relación: Una zona tiene muchas lecturas
    lecturas = relationship("Lectura", back_populates="zona")