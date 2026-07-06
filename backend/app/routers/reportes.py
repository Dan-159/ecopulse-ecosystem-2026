from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func

from backend.app.database import get_db
from backend.app.models.zona import Zona
from backend.app.models.lectura import Lectura

router = APIRouter(prefix="/reportes",tags=["Reportes"])

@router.get("/promedio-general", 
            summary="Promedio de contaminación general (Nivel global)", 
            description="Calcula el promedio general de contaminación basado en todas las lecturas registradas.")
def promedio_contaminacion(db: Session = Depends(get_db)):
    # Ejecutamos una consulta que nos devuelve el total de lecturas 
    # y el promedio de cada contaminante 
    # usando funciones agregadas de SQLAlchemy 
    resultado = db.query(
        func.count(Lectura.id).label("total"),
        func.avg(Lectura.lectura_de_co2).label("co2"),
        func.avg(Lectura.lectura_de_nox).label("nox"),
        func.avg(Lectura.lectura_de_pm25).label("pm25")
    ).first()
    
    # Si el total es 0 o None, significa que no hay lecturas
    if not resultado or resultado.total == 0:
        raise HTTPException(status_code=404, detail="No se encontraron lecturas para calcular el promedio.")
    
    co2_avg = resultado.co2 if resultado.co2 is not None else 0.0
    nox_avg = resultado.nox if resultado.nox is not None else 0.0
    pm25_avg = resultado.pm25 if resultado.pm25 is not None else 0.0

    # lógica de normalización
    co2_normalizado = (co2_avg - 400) / 800
    nox_normalizado = nox_avg / 150
    pm25_normalizado = pm25_avg / 150

    # 4. Calcular el índice compuesto global
    indice_global = round(0.2 * co2_normalizado + 0.3 * nox_normalizado + 0.5 * pm25_normalizado, 2)
    
    return {
        "total_lecturas": resultado.total,
        "promedio_co2": round(co2_avg, 2),
        "promedio_nox": round(nox_avg, 2),
        "promedio_pm25": round(pm25_avg, 2),
        "indice_global": indice_global 
    }

@router.get("/promedio-por-zona", 
summary="Promedio de contaminación por zona", 
description="Calcula el promedio de contaminación para cada zona, basado en las lecturas de sus sensores.")
def promedio_contaminacion_por_zona(db: Session = Depends(get_db)):
    # Validar que existan lecturas para calcular el promedio
    lectura_validar=db.query(Lectura).first()
    if not lectura_validar:
        raise HTTPException(status_code=404,detail="No se encontraron lecturas para calcular el promedio.")
    
    # Calcular el promedio de contaminación por zona 
    # usando funciones agregadas de SQLAlchemy
    promedios = (
        db.query(
            Lectura.id_zona,
            func.avg(Lectura.lectura_de_co2).label("promedio_co2"),
            func.avg(Lectura.lectura_de_nox).label("promedio_nox"),
            func.avg(Lectura.lectura_de_pm25).label("promedio_pm25")
        )
        .group_by(Lectura.id_zona)
        .all()
    )
    
    # Convertir los resultados a una lista de diccionarios para retornar
    resultado = []
    for zona in promedios:
        resultado.append({
            "id_zona": zona.id_zona,
            "nombre_zona": db.query(Zona).filter(Zona.id_zona == zona.id_zona).first().nombre,
            "promedio_co2": zona.promedio_co2,
            "promedio_nox": zona.promedio_nox,
            "promedio_pm25": zona.promedio_pm25
        })
    
    # Retornar la lista de promedios por zona
    return resultado

@router.get("/top-3-zonas-contaminadas", 
summary="Top 3 zonas más contaminadas", 
description="Retorna una lista con las 3 zonas más contaminadas basado en el promedio de sus lecturas.")
def top_3_zonas(db: Session = Depends(get_db)):
    # 1. Validar que existan lecturas
    if not db.query(Lectura).first():
        raise HTTPException(status_code=404, detail="No se encontraron lecturas para calcular el ranking.")
    
    # 2. Traemos el nombre de la zona haciendo un JOIN directo en la base de datos
    zonas = (
        db.query(
            Lectura.id_zona,
            Zona.nombre.label("nombre_zona"),
            func.avg(Lectura.lectura_de_co2).label("co2"),
            func.avg(Lectura.lectura_de_nox).label("nox"),
            func.avg(Lectura.lectura_de_pm25).label("pm25")
        )
        .join(Zona, Lectura.id_zona == Zona.id_zona)
        .group_by(Lectura.id_zona, Zona.nombre)
        .all()
    )
    
    ranking = []

    for zona in zonas:
        # Tu lógica de normalización
        co2_normalizado = (zona.co2 - 400) / 800
        nox_normalizado = zona.nox / 150
        pm25_normalizado = zona.pm25 / 150

        indice = round(0.2 * co2_normalizado + 0.3 * nox_normalizado + 0.5 * pm25_normalizado, 2)

        ranking.append({
            "id_zona": zona.id_zona,
            "nombre_zona": zona.nombre_zona,
            "indice": indice
        })

    # Ordenar y cortar el Top 3
    ranking.sort(key=lambda x: x["indice"], reverse=True)
    return ranking[:3]
    

@router.get("/zonas-estados", 
summary="Zonas por estado de contaminación",
description="Retorna una lista con las zonas clasificadas por su nivel de contaminación.")
def zonas_por_estado(db: Session = Depends(get_db)):
    # Validar que existan lecturas para identificar zonas críticas
    if not db.query(Lectura).first():
        raise HTTPException(status_code=404, detail="No se encontraron lecturas para identificar el estado de las zonas.")
    
    # Para cada zona, calculamos un índice de contaminación 
    # basado en el promedio de sus lecturas
    zonas = (
    db.query(
        Lectura.id_zona,
        func.avg(Lectura.lectura_de_co2).label("co2"),
        func.avg(Lectura.lectura_de_nox).label("nox"),
        func.avg(Lectura.lectura_de_pm25).label("pm25")
    )
    .group_by(Lectura.id_zona)
    .all()
    )
    
    # Normalizamos los valores para cada contaminante y calculamos un índice compuesto 
    # para luego clasificar las zonas en estados de contaminación (Bajo, Moderado, Alto, Crítico)
    zonas_estados = []

    for zona in zonas:
        co2_normalizado = (zona.co2 - 400) / 800
        nox_normalizado = zona.nox / 150
        pm25_normalizado = zona.pm25 / 150

        indice = round(0.2*co2_normalizado + 0.3*nox_normalizado + 0.5*pm25_normalizado, 2)
        
        if indice >= 0.80:
            estado = "CRITICO"
        elif indice >= 0.60:
            estado = "ALTO"
        elif indice >= 0.40:
            estado = "MODERADO"
        else:
            estado = "BAJO"
        
        zonas_estados.append({
            "id_zona": zona.id_zona,
            "nombre_zona": db.query(Zona).filter(Zona.id_zona == zona.id_zona).first().nombre,
            "indice": indice,
            "estado": estado,
        })

    return zonas_estados