from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.models.lectura import Lectura
from backend.app.schemas.lectura_schema import LecturaCreate, LecturaResponse
from backend.app.auth.jwt import verificar_token

router = APIRouter(prefix="/lecturas",tags=["Lecturas"])

# Crear lectura (datos IoT)
@router.post("/", response_model=LecturaResponse,status_code=201,
summary="Registrar una nueva lectura",
description="Inserta una nueva lectura de un sensor específico en la base de datos.")
def crear_lectura(lectura: LecturaCreate, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    # Validar que la zona asociada a la lectura exista
    zona_asociada = (db.query(Zona.id_zona).filter(Zona.id_zona == lectura.id_zona)).first()    
    if not zona_asociada:
        raise HTTPException(status_code=404,detail="La lectura debe estar asociada a una zona existente.")
    
    # Crear la nueva lectura
    nueva = Lectura(id_zona=lectura.id_zona, 
                    lectura_de_co2=lectura.lectura_de_co2, 
                    lectura_de_nox=lectura.lectura_de_nox, 
                    lectura_de_pm25=lectura.lectura_de_pm25)
    
    # Guardar la nueva lectura en la base de datos
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    
    # Retornar la lectura creada
    return nueva

# Listar todas las lecturas
@router.get("/", response_model=list[LecturaResponse], 
summary="Listar todas las lecturas",
description="Retorna una lista con todas las lecturas registradas en la base de datos.")
def listar_lecturas(db: Session = Depends(get_db)):
    # Validar que existan lecturas registradas
    if not db.query(Lectura.id).first():
        raise HTTPException(status_code=404, detail="No se encontraron lecturas registradas")
    
    # Retornar la lista de lecturas
    return db.query(Lectura).all()

# Listar lecturas por zona
@router.get("/zona", response_model=list[LecturaResponse],
summary="Listar lecturas por zona",
description="Retorna una lista con las lecturas registradas para una zona específica.")
def listar_lecturas_por_zona(id_zona: int, db: Session = Depends(get_db)):
    # Validar que la zona exista
    if not db.query(Zona).filter(Zona.id_zona == id_zona).first():
        raise HTTPException(status_code=404, detail="La zona especificada no existe")

    # Retornar la lista de lecturas para esa zona
    return db.query(Lectura).filter(Lectura.id_zona == id_zona).all()