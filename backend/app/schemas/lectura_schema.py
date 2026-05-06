from pydantic import BaseModel
from datetime import datetime

# CREATE
class LecturaCreate(BaseModel):
    valor: float
    tipo: str
    sensor_id: int

# RESPONSE
class LecturaResponse(BaseModel):
    id: int
    valor: float
    tipo: str
    fecha: datetime
    sensor_id: int

    class Config:
        from_attributes = True