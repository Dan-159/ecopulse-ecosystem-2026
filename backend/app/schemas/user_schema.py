from pydantic import BaseModel
# Para crear un nuevo usuario
class UserCreate(BaseModel):
    username: str
    password: str

# Para el login de un usuario
class UserLogin(BaseModel):
    username: str
    password: str