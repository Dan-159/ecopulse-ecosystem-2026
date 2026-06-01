from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.sensor import Sensor
from backend.app.models.zona import Zona
from backend.app.schemas.sensor_schema import SensorCreate, SensorResponse
from backend.app.auth.jwt import verificar_token

router = APIRouter(prefix="/sensores",tags=["Sensores"])

# 👉 Crear sensor
@router.post("/", response_model=SensorResponse, status_code=201, 
summary="Registrar un nuevo sensor", 
description="Inserta un nuevo sensor en una zona específica. "
"El ID del sensor se genera automáticamente basado en el número de sensores existentes en esa zona.")
def crear_sensor(sensor: SensorCreate, db: Session = Depends(get_db), usuario: str = Depends(verificar_token)):
    if (sensor.tipo_sensor not in ["co2", "nox", "pm25"]):
        raise HTTPException(status_code=400, detail="Tipo de sensor no válido (permitidos: co2, nox, pm25)")

    zona_sensor = db.query(Zona).filter(Zona.id_zona == sensor.id_zona).first()
    if not zona_sensor:
        raise HTTPException(status_code=404, detail="La zona especificada no existe")
    # 1. Averiguar cuál es el número máximo actual de sensor EN ESA ZONA
    max_id = db.query(func.max(Sensor.id_zona_sensor)).filter(Sensor.id_zona == sensor.id_zona).scalar()
    
    # 2. Si no hay sensores, empezamos en 1. Si hay, sumamos 1.
    siguiente_id = (max_id or 0) + 1
    
    nuevo_sensor = Sensor(
        id_zona=sensor.id_zona,
        id_zona_sensor=siguiente_id,
        nombre=sensor.nombre,
        tipo_sensor=sensor.tipo_sensor
    )
    
    db.add(nuevo_sensor)
    db.commit()
    db.refresh(nuevo_sensor)
    return nuevo_sensor


# 👉 Listar sensores
@router.get("/", response_model=list[SensorResponse], 
summary="Listar todos los sensores",
description="Retorna una lista con todos los sensores registrados en la base de datos.")
def listar_sensores(db: Session = Depends(get_db)):
    return db.query(Sensor).all()