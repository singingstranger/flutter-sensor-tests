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
