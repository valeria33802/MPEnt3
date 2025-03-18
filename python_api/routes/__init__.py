# python_api/routes/__init__.py
from .login import router as login_router

# Puedes agregar otros routers aquí y luego importarlos en main.py si lo prefieres:
routers = [login_router]
