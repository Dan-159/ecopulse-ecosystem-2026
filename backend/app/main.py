from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.database import engine, Base
from backend.app.routers import zonas_router, sensores_router, lecturas_router, reportes_router, auth_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
title="EcoPulse - Sistema de Monitoreo de Emisiones y Calidad del Aire Urbano-Industrial",
description="""
API robusta para la gestión y monitoreo de la contaminación del aire en zonas 
urbanas aledañas a parques industriales.
Permite la telemetría de sensores en tiempo real y el cálculo de niveles de riesgo.
**Entidades principales:**
* **Zonas:** Puntos de monitoreo físico.
* **Sensores:** Dispositivos que capturan datos ambientales.
* **Lecturas:** Datos capturados por sensores.
* **Reportes:** Análisis de criticidad basado en umbrales.
""",
version="1.0.0",
terms_of_service="http://unmsm.edu.pe/terms/",
contact={
    "name": "Soporte Técnico EcoPulse - FISI",
    "url": "http://fisi.unmsm.edu.pe",
    "email": "desarrollo.ecopulse@unmsm.edu.pe",
    },
license_info={
    "name": "Apache 2.0",
    "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
    },
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["Inicio"], summary="Bienvenida", description="Mensaje de bienvenida a la API EcoPulse")
def root():
    return {"msg": "EcoPulse backend funcionando"}

app.include_router(auth_router)
app.include_router(zonas_router)
app.include_router(sensores_router)
app.include_router(lecturas_router)
app.include_router(reportes_router)


