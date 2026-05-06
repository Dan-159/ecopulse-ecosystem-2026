from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Sensor(Base):
    __tablename__ = "sensores"

    id = Column(Integer, primary_key=True, index=True)
    
    nombre = Column(String, nullable=False)
    
    tipo = Column(String, nullable=False)  
    # Ej: "PM2.5", "CO2", "NOx"
    
    valor_actual = Column(Float, default=0.0)

    zona_id = Column(Integer, ForeignKey("zonas.id"))

    zona = relationship("Zona", backref="sensores")
    lecturas = relationship("Lectura", back_populates="sensor")