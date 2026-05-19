from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey, ForeignKeyConstraint
from datetime import datetime
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Lectura(Base):
    __tablename__ = "lecturas"
    
    id = Column(Integer, primary_key=True, index=True) # ID global para la lectura
    
    # Apuntamos a la clave compuesta del Sensor
    id_zona = Column(Integer, nullable=False)
    id_zona_sensor = Column(Integer, nullable=False)
    tipo_lectura = Column(String, nullable=False)  # Para facilitar consultas por tipo de sensor
    valor = Column(Float, nullable=False)
    fecha = Column(DateTime, default=datetime.utcnow)

    # FK Compuesta: Apunta exactamente al sensor correcto en la zona correcta
    __table_args__ = (
        ForeignKeyConstraint(
            ['id_zona', 'id_zona_sensor'], 
            ['sensores.id_zona', 'sensores.id_zona_sensor']
        ),
    )

    # Relación
    sensor = relationship("Sensor", back_populates="lecturas")