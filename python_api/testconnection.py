# python_api/test_connection.py
import asyncio
import httpx
import os

NODE_SERVICE_URL = os.getenv("NODE_SERVICE_URL", "http://node:3000")

async def test_node_connection():
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{NODE_SERVICE_URL}/ping")
            print(f"Status: {response.status_code}, Response: {response.text}")
        except Exception as e:
            print(f"Error: {str(e)}")

if __name__ == "__main__":
    asyncio.run(test_node_connection())

   # python test_connection.py