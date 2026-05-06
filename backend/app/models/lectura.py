from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from datetime import datetime
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Lectura(Base):
    __tablename__ = "lecturas"

    id = Column(Integer, primary_key=True, index=True)

    valor = Column(Float, nullable=False)
    tipo = Column(String, nullable=False)

    fecha = Column(DateTime, default=datetime.utcnow)

    sensor_id = Column(Integer, ForeignKey("sensores.id"))

    sensor = relationship("Sensor", back_populates="lecturas")