from pydantic import BaseModel

# CREATE
class SensorCreate(BaseModel):
    nombre: str
    tipo: str
    zona_id: int

# RESPONSE
class SensorResponse(BaseModel):
    id: int
    nombre: str
    tipo: str
    valor_actual: float
    zona_id: int

    class Config:
        from_attributes = True