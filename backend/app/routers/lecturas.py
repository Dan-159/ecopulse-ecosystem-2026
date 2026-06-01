from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.lectura import Lectura
from backend.app.models.sensor import Sensor
from backend.app.schemas.lectura_schema import LecturaCreate, LecturaResponse
from backend.app.auth.jwt import verificar_token

router = APIRouter(prefix="/lecturas",tags=["Lecturas"])

# 👉 Crear lectura (datos IoT)
@router.post("/", response_model=LecturaResponse,status_code=201,
summary="Registrar una nueva lectura",
description="Inserta una nueva lectura de un sensor específico en la base de datos.")
def crear_lectura(lectura: LecturaCreate, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    sensor_asociado = (
            db.query(Sensor)
            .filter(
                Sensor.id_zona == lectura.id_zona, 
                Sensor.id_zona_sensor == lectura.id_zona_sensor
            )
            .first()
        )    
    if not sensor_asociado:
        raise HTTPException(status_code=404,detail="La lectura debe estar asociada a un sensor existente.")
    
    nueva = Lectura(valor=lectura.valor, id_zona=lectura.id_zona, id_zona_sensor=lectura.id_zona_sensor, tipo_lectura=sensor_asociado.tipo_sensor)
    sensor_asociado.lecturas_registradas += 1
    sensor_asociado.total_registrado += lectura.valor
    sensor_asociado.ultima_lectura = lectura.valor
    db.add(sensor_asociado)
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva


# 👉 Listar lecturas
@router.get("/", response_model=list[LecturaResponse], 
summary="Listar todas las lecturas",
description="Retorna una lista con todas las lecturas registradas en la base de datos.")
def listar_lecturas(db: Session = Depends(get_db)):
    return db.query(Lectura).all()