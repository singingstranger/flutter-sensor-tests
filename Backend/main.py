from fastapi import FastAPI
import random
import math
import time

app = FastAPI()

machine_state = {
    "running": False,
    "speed": 1.0
}

start_time = time.time()

@app.get("/sensor")
def get_sensor():
    if not machine_state["running"]:
        return {"value": 0}
    
    t = time.time() - start_time
    value = machine_state["speed"]*(50+30*math.sin(t)+random.uniform(-10,10))
    return{"value": round(value,2)}

@app.post("/command")
def send_command(cmd: dict):
    global machine_state
    if "running" in cmd:
        machine_state["running"] = cmd["running"]

    if "speed" in cmd:
        machine_state["speed"] = cmd["speed"]
    
    return {"status": "ok", "state": machine_state}

from fastapi import WebSocket
import asyncio

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    async def sender():
        while True:
            if not machine_state["running"]:
                value = 0
            else:
                t = time.time() - start_time
                value = machine_state["speed"] * (50 + 30 * math.sin(t))

            await websocket.send_json({
                "value": round(value, 2),
                "running": machine_state["running"]
            })

            await asyncio.sleep(0.5)

    async def receiver():
        while True:
            data = await websocket.receive_json()
            print("Websocket command:", data)

            machine_state["running"] = data.get("running", True)
            machine_state["speed"] = data.get("speed", 1.0)
    
    await asyncio.gather(sender(), receiver())
        