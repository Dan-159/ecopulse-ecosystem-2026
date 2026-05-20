from pydantic import BaseModel

#  FORM
class SensorCreate(BaseModel):
    id_zona: int
    nombre: str
    tipo_sensor: str
    
# RESPONSE
class SensorResponse(BaseModel):
    id_zona: int
    id_zona_sensor: int
    nombre: str
    tipo_sensor: str
    
    class Config:
        from_attributes = True