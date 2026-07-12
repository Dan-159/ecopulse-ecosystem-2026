from datetime import datetime, timedelta
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

SECRET_KEY = "ecopulse_secret_key_2026"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")
def crear_token(data: dict):
    to_encode = data.copy()
    if(data["sub"] == "admin_fisi"):
        expire = datetime.utcnow() + timedelta(days=1)
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return token

async def verificar_token(token: str=Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="No se pudo validar el token de acceso",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        return username 
    except JWTError:
        raise credentials_exception