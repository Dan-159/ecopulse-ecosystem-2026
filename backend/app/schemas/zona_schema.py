from pydantic import BaseModel

# 👉 Para crear una zona
class ZonaCreate(BaseModel):
    nombre: str
    ubicacion: str

# 👉 Para devolver una zona (respuesta)
class ZonaResponse(BaseModel):
    id: int
    nombre: str
    ubicacion: str

    class Config:
        from_attributes = True