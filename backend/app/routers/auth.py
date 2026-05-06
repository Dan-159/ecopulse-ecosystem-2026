from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.schemas.user_schema import UserCreate, UserLogin
from backend.app.auth.jwt import crear_token

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)

# 👉 Registro
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):

    nuevo_user = User(
        username=user.username,
        password=user.password  # (luego lo mejoramos con hash)
    )

    db.add(nuevo_user)
    db.commit()
    db.refresh(nuevo_user)

    return {"msg": "Usuario creado"}

# 👉 Login
@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):

    db_user = db.query(User).filter(User.username == user.username).first()

    if not db_user or db_user.password != user.password:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    token = crear_token({"sub": db_user.username})

    return {"access_token": token, "token_type": "bearer"}