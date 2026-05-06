from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.lectura import Lectura
from backend.app.schemas.lectura_schema import LecturaCreate, LecturaResponse

router = APIRouter(
    prefix="/lecturas",
    tags=["Lecturas"]
)

# 👉 Crear lectura (datos IoT)
@router.post("/", response_model=LecturaResponse)
def crear_lectura(lectura: LecturaCreate, db: Session = Depends(get_db)):
    nueva = Lectura(
        valor=lectura.valor,
        tipo=lectura.tipo,
        sensor_id=lectura.sensor_id
    )
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva


# 👉 Listar lecturas
@router.get("/", response_model=list[LecturaResponse])
def listar_lecturas(db: Session = Depends(get_db)):
    return db.query(Lectura).all()