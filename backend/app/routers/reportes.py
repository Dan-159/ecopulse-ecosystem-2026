from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.models.sensor import Sensor
from backend.app.models.lectura import Lectura

router = APIRouter(prefix="/reportes",tags=["Reportes"])

@router.get("/promedio", 
summary="Promedio de contaminación", 
description="Calcula el promedio general de contaminación basado en todas las lecturas registradas en la base de datos.")
def promedio_contaminacion(db: Session = Depends(get_db)):
    lecturas_co2= db.query(Lectura).filter(Lectura.tipo_lectura == "co2").all()
    lecturas_nox = db.query(Lectura).filter(Lectura.tipo_lectura == "nox").all()
    lecturas_pm25 = db.query(Lectura).filter(Lectura.tipo_lectura == "pm25").all()
    lecturas=[lecturas_co2,lecturas_nox,lecturas_pm25]
    if not lecturas:
        raise HTTPException(status_code=404,detail="No se encontraron lecturas para calcular el promedio.")
    promedio_co2 = sum(l.valor for l in lecturas_co2) / len(lecturas_co2) if lecturas_co2 else 0
    promedio_nox = sum(l.valor for l in lecturas_nox) / len(lecturas_nox) if lecturas_nox else 0
    promedio_pm25 = sum(l.valor for l in lecturas_pm25) / len(lecturas_pm25) if lecturas_pm25 else 0
    total_lecturas = len(lecturas_co2) + len(lecturas_nox) + len(lecturas_pm25)
    return {
        "total_lecturas": total_lecturas,
        "promedio_co2": promedio_co2,
        "promedio_nox": promedio_nox,
        "promedio_pm25": promedio_pm25
    }

@router.get("/zonas-más-contaminadas", 
summary="Zonas más contaminadas", 
description="Retorna una lista con las zonas más contaminadas basado en el promedio de sus sensores.")
def zonas_mas_contaminadas(db: Session = Depends(get_db)):
    zonas = db.query(Zona).options(
        joinedload(Zona.sensores).joinedload(Sensor.lecturas)
    ).all()

    zonas_contaminadas = []

    for zona in zonas:
        total = 0
        count = 0

        for sensor in zona.sensores:
            for lectura in sensor.lecturas:
                total += lectura.valor
                count += 1

        if count > 0:
            promedio = total / count
            zonas_contaminadas.append({
                "zona": zona.nombre,
                "promedio_general": promedio
            })

    zonas_contaminadas.sort(key=lambda x: x["promedio_general"], reverse=True)
    return zonas_contaminadas[:5]  # Retorna las 5 zonas más contaminadas

@router.get("/zonas-criticas", 
summary="Zonas críticas", 
description="Retorna una lista con las zonas que tienen un nivel de contaminación por encima del umbral crítico.")
def zonas_criticas(db: Session = Depends(get_db)):
    umbral_critico = 50  # Este valor puede ser ajustado según los estándares de contaminación
    zonas = db.query(Zona).options(
        joinedload(Zona.sensores).joinedload(Sensor.lecturas)
    ).all()

    zonas_criticas = []

    for zona in zonas:
        total = 0
        count = 0

        for sensor in zona.sensores:
            for lectura in sensor.lecturas:
                total += lectura.valor
                count += 1

        if count > 0:
            promedio = total / count
            if promedio > umbral_critico:
                zonas_criticas.append({
                    "zona": zona.nombre,
                    "promedio": promedio
                })

    return zonas_criticas