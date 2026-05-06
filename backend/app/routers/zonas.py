from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.schemas.zona_schema import ZonaCreate, ZonaResponse

router = APIRouter(
    prefix="/zonas",
    tags=["Zonas"]
)

# 👉 Crear zona
@router.post("/", response_model=ZonaResponse)
def crear_zona(zona: ZonaCreate, db: Session = Depends(get_db)):
    nueva_zona = Zona(
        nombre=zona.nombre,
        ubicacion=zona.ubicacion
    )
    db.add(nueva_zona)
    db.commit()
    db.refresh(nueva_zona)
    return nueva_zona

# 👉 Listar zonas
@router.get("/", response_model=list[ZonaResponse])
def listar_zonas(db: Session = Depends(get_db)):
    zonas = db.query(Zona).all()
    return zonas