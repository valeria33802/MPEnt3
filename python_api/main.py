# python_api/main.py
from fastapi import FastAPI
from routes import routers  

from dotenv import load_dotenv
load_dotenv()

app = FastAPI(title="API Proxy - Python para Servicios Node")

# Incluir todos los routers de la lista importada
for router in routers:
    app.include_router(router, prefix="/api")