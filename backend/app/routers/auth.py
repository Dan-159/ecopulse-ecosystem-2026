from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.schemas.user_schema import UserCreate
from backend.app.auth.jwt import crear_token

router = APIRouter(prefix="/auth",tags=["Auth"])

# 👉 Registro
@router.post("/register", status_code=201,
summary="Registrar un nuevo usuario",
description="Crea un nuevo usuario en el sistema.")
def register(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(status_code=400, detail="El nombre de usuario ya existe")
    nuevo_user = User(
        username=user.username,
        password=user.password  # (luego lo mejoramos con hash)
    )
    db.add(nuevo_user)
    db.commit()
    db.refresh(nuevo_user)
    return {"msg": "Usuario creado"}

# 👉 Login
@router.post("/login", 
summary="Iniciar sesión",
description="Permite a un usuario iniciar sesión en el sistema.")
def login(form_data: OAuth2PasswordRequestForm=Depends(), db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == form_data.username).first()
    if not db_user or db_user.password != form_data.password:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    token = crear_token({"sub": form_data.username})
    return {"access_token": token, "token_type": "bearer"}