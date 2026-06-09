from sqlalchemy import Column, ForeignKey, Integer, Float, DateTime
from datetime import datetime
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Lectura(Base):
    __tablename__ = "lecturas"
    # ID global para la lectura
    id = Column(Integer, primary_key=True, index=True) 
    
    # Dato para identificar la zona a la que pertenece esta lectura
    id_zona = Column(Integer, ForeignKey("zonas.id_zona"), nullable=False)
    
    # Lecturas específicas para cada tipo de contaminante (valores actuales)
    lectura_de_co2 = Column(Float, default=0.0)     #ppm (partes por millón), rango típico: 400-1200 ppm
    lectura_de_nox = Column(Float, default=0.0)     #ppb (partes por mil millones), rango típico: 0-100 ppb
    lectura_de_pm25 = Column(Float, default=0.0)    #µg/m³ (microgramos por metro cúbico), rango típico: 0-150 µg/m³
    
    # Fecha de la lectura
    fecha = Column(DateTime, default=datetime.utcnow)

    # Relación: Cada lectura pertenece a una zona específica
    zona = relationship("Zona", back_populates="lecturas")