from pydantic import BaseModel
from datetime import datetime

# CREATE
class LecturaCreate(BaseModel):
    id_zona: int
    id_zona_sensor: int
    valor: float
    
# RESPONSE
class LecturaResponse(BaseModel):
    id: int
    id_zona: int
    id_zona_sensor: int
    tipo_lectura: str
    valor: float
    fecha: datetime

    class Config:
        from_attributes = True