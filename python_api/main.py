# python_api/main.py
from fastapi import FastAPI
from routes import login  # O, si en __init__.py ya exportas el router, puedes importarlo directamente

from dotenv import load_dotenv
load_dotenv()


app = FastAPI(title="API Proxy - Python para Servicios Node")

# Incluye el router con un prefijo (por ejemplo, /api)
app.include_router(login.router, prefix="/api")

# Aquí podrías incluir otros routers en el futuro
