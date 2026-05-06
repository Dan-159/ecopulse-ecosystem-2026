from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.models.sensor import Sensor
from backend.app.models.lectura import Lectura

router = APIRouter(
    prefix="/reportes",
    tags=["Reportes"]
)
@router.get("/promedio")
def promedio_contaminacion(db: Session = Depends(get_db)):

    lecturas = db.query(Lectura).all()

    if not lecturas:
        return {"mensaje": "No hay datos"}

    total = sum(l.valor for l in lecturas)
    promedio = total / len(lecturas)

    return {
        "total_lecturas": len(lecturas),
        "promedio_general": promedio
    }
@router.get("/zonas-contaminadas")
def zonas_mas_contaminadas(db: Session = Depends(get_db)):

    zonas = db.query(Zona).all()

    resultado = []

    for zona in zonas:
        valores = []

        for sensor in zona.sensores:
            for lectura in sensor.lecturas:
                valores.append(lectura.valor)

        if valores:
            promedio = sum(valores) / len(valores)
        else:
            promedio = 0

        resultado.append({
            "zona": zona.nombre,
            "ubicacion": zona.ubicacion,
            "promedio_contaminacion": promedio
        })

    return sorted(resultado, key=lambda x: x["promedio_contaminacion"], reverse=True)
@router.get("/zonas-criticas")
def zonas_criticas(db: Session = Depends(get_db)):

    zonas = db.query(Zona).all()

    criticas = []

    for zona in zonas:
        total = 0
        count = 0

        for sensor in zona.sensores:
            for lectura in sensor.lecturas:
                total += lectura.valor
                count += 1

        if count > 0:
            promedio = total / count

            if promedio > 50:  # umbral crítico simple
                criticas.append({
                    "zona": zona.nombre,
                    "nivel": "CRÍTICO 🔴",
                    "promedio": promedio
                })

    return criticas