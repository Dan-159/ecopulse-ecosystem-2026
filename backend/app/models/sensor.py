from sqlalchemy import Column, Integer, String, ForeignKey, PrimaryKeyConstraint
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Sensor(Base):
    __tablename__ = "sensores"
    
    id_zona = Column(Integer, ForeignKey("zonas.id_zona"), nullable=False)
    id_zona_sensor = Column(Integer, nullable=False) # 1, 2, 3... por cada zona
    
    nombre = Column(String, nullable=False)
    tipo_sensor = Column(String, nullable=False)  # Ej: "PM2.5", "CO2", "NOx"
    
    #Datos a guardar en el sensor
    lecturas_registradas = Column(Integer, default=0)
    total_registrado = Column(Integer, default=0)
    ultima_lectura = Column(Integer, default=0)

    # CLAVE PRIMARIA COMPUESTA: Así aseguras la unicidad por zona
    __table_args__ = (PrimaryKeyConstraint('id_zona', 'id_zona_sensor'),)

    # Relaciones
    zona = relationship("Zona", back_populates="sensores")
    lecturas = relationship("Lectura", back_populates="sensor", cascade="all, delete-orphan")