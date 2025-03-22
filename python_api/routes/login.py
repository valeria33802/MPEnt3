# python_api/routes/login.py
from fastapi import APIRouter, HTTPException
from models import LoginRequest, LoginResponse
import httpx
import os

router = APIRouter()

NODE_SERVICE_URL = os.getenv("NODE_SERVICE_URL", "http://node:3000")  # Por ejemplo, si el servicio Node se llama "node" en Docker

@router.post("/login", response_model=LoginResponse)
async def login_endpoint(login_data: LoginRequest):
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{NODE_SERVICE_URL}/login", json=login_data.dict())
            response.raise_for_status()
            data = response.json()
            return data
    except httpx.HTTPStatusError as exc:

        error_detail = exc.response.text
        if exc.response.status_code == 401:
            raise HTTPException(
                status_code=401,
                detail=f"Usuario no reconocido o contraseña incorrecta. Detalle: {error_detail}"
            )
        else:
            raise HTTPException(
                status_code=exc.response.status_code,
                detail=f"Error en servicio Node. Código {exc.response.status_code}: {error_detail}"
            )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error interno del servidor: {str(e)}"
        )

