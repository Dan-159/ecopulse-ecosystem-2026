from fastapi import FastAPI
from backend.app.database import engine, Base

from backend.app.routers import zonas_router, sensores_router, lecturas_router, reportes_router, auth_router

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(zonas_router)
app.include_router(sensores_router)
app.include_router(lecturas_router)
app.include_router(reportes_router)
app.include_router(auth_router)

@app.get("/")
def root():
    return {"msg": "EcoPulse backend funcionando"}