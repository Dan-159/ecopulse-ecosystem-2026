from pydantic import BaseModel
from datetime import datetime

# FORM (para crear una nueva lectura)
class LecturaCreate(BaseModel):
    # Dato para identificar la zona a la que pertenece la lectura
    id_zona: int
    
    # Lecturas específicas para cada tipo de contaminante (valores actuales)
    lectura_de_co2: float
    lectura_de_nox: float
    lectura_de_pm25: float

# RESPONSE (para devolver una lectura)
class LecturaResponse(BaseModel):
    #Datos para identificar la lectura y el sensor al que pertenece
    id: int
    id_zona: int
    
    # Lecturas específicas para cada tipo de contaminante (valores actuales)
    lectura_de_co2: float
    lectura_de_nox: float
    lectura_de_pm25: float
    
    #Fecha de la lectura
    fecha: datetime

    class Config:
        from_attributes = True