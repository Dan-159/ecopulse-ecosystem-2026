from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.schemas.zona_schema import ZonaCreate, ZonaResponse
from backend.app.auth.jwt import verificar_token

router = APIRouter(prefix="/zonas",tags=["Zonas"])

# 👉 Crear zona
@router.post("/", response_model=ZonaResponse, status_code=201,
summary="Registrar una nueva zona de monitoreo",
description="Inserta una zona física (ej. urbanización, parque industrial) en la base de datos relacional.")
def crear_zona(zona: ZonaCreate, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    nueva_zona = Zona(nombre=zona.nombre, ubicacion=zona.ubicacion)
    db.add(nueva_zona)
    db.commit()
    db.refresh(nueva_zona)
    return nueva_zona

# 👉 Listar zonas
@router.get("/", response_model=list[ZonaResponse], 
summary="Listar todas las zonas de monitoreo",
description="Retorna una lista con todas las zonas físicas registradas en la base de datos.")
def listar_zonas(db: Session = Depends(get_db)):
    zonas = db.query(Zona).all()
    return zonas

#👉 Editar zona
@router.put("/{id_zona}", response_model=ZonaResponse, 
summary="Editar una zona de monitoreo",
description="Actualiza la información de una zona física existente en la base de datos.")
def editar_zona(id_zona: int, zona: ZonaCreate, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    if not db.query(Zona).filter(Zona.id_zona == id_zona).first():
        raise HTTPException(status_code=404, detail="Zona no encontrada")
    zona_db = db.query(Zona).filter(Zona.id_zona == id_zona).first()
    
    zona_db.nombre = zona.nombre
    zona_db.ubicacion = zona.ubicacion
    db.commit()
    db.refresh(zona_db)
    return zona_db
    

#👉 Eliminar zona
@router.delete("/{id_zona}", status_code=204, 
summary="Eliminar una zona de monitoreo",
description="Elimina una zona física existente de la base de datos.")
def eliminar_zona(id_zona: int, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    if not db.query(Zona).filter(Zona.id_zona == id_zona).first():
        raise HTTPException(status_code=404, detail="Zona no encontrada")
    
    zona_db = db.query(Zona).filter(Zona.id_zona == id_zona).first()
    db.delete(zona_db)
    db.commit()