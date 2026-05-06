from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.sensor import Sensor
from backend.app.schemas.sensor_schema import SensorCreate, SensorResponse

router = APIRouter(
    prefix="/sensores",
    tags=["Sensores"]
)

# 👉 Crear sensor
@router.post("/", response_model=SensorResponse)
def crear_sensor(sensor: SensorCreate, db: Session = Depends(get_db)):
    nuevo_sensor = Sensor(
        nombre=sensor.nombre,
        tipo=sensor.tipo,
        zona_id=sensor.zona_id
    )
    db.add(nuevo_sensor)
    db.commit()
    db.refresh(nuevo_sensor)
    return nuevo_sensor


# 👉 Listar sensores
@router.get("/", response_model=list[SensorResponse])
def listar_sensores(db: Session = Depends(get_db)):
    return db.query(Sensor).all()