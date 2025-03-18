# python_api/routes/login.py
from fastapi import APIRouter, HTTPException
from models import LoginRequest, LoginResponse
import httpx
import os

router = APIRouter()

# Define la URL del servicio Node; asegúrate de configurar NODE_SERVICE_URL en tu .env o en variables del entorno.
NODE_SERVICE_URL = os.getenv("NODE_SERVICE_URL", "http://node:8000")  # Por ejemplo, si el servicio Node se llama "node" en Docker

@router.post("/login", response_model=LoginResponse)
async def login_endpoint(login_data: LoginRequest):
    try:
        # Llama al endpoint /login del servicio Node, pasando el JSON con los datos
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{NODE_SERVICE_URL}/login", json=login_data.dict())
            response.raise_for_status()
            data = response.json()
            return data
    except httpx.HTTPStatusError as exc:
        # Si el servicio Node responde con error, reenvía el error a la API
        if exc.response.status_code == 401:
            raise HTTPException(status_code=401, detail="Usuario no reconocido o contraseña incorrecta")
        else:
            raise HTTPException(status_code=exc.response.status_code, detail="Error en servicio Node")
    except Exception as e:
        raise HTTPException(status_code=500, detail="Error interno del servidor")
