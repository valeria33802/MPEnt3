# python_api/models.py
from pydantic import BaseModel

class LoginRequest(BaseModel):
    nombreusuario: str
    contrasenia: str

class LoginResponse(BaseModel):
    success: bool
    mensaje: str
    posicion: str | None = None  # Posición es opcional
