from fastapi import FastAPI
import random
import math
import time
import paho.mqtt.client as mqtt
import json
import asyncio

current_value = 0

from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    asyncio.create_task(mqtt_publisher())
    yield

app = FastAPI(lifespan=lifespan)

machine_state = {
    "running": False,
    "speed": 1.0
}

start_time = time.time()


### MQTT
async def mqtt_publisher():
    while True:
        if not machine_state["running"]:
            value = 0
        else:
            t = time.time() - start_time
            value = machine_state["speed"] * (50 + 30 * math.sin(t))

        mqtt_client.publish(
            "sensor/value",
            json.dumps({
                "value": round(value, 2),
                "running": machine_state["running"]
            })
        )

        await asyncio.sleep(0.5)


def on_connect(client, userdata, flags, rc):
    print("MQTT connected with result code ", rc)
    client.subscribe("machine/command")

def on_message(client, userdata, msg):
    global machine_state
    try:
        payload = json.loads(msg.payload.decode())
        print("MQTT command received:", payload)

        if "running" in payload:
            machine_state["running"] = payload["running"]
        if "speed" in payload:
            machine_state["speed"] = payload["speed"]

    except Exception as e:
        print("MQTT error: ", e)


mqtt_client = mqtt.Client()
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message
mqtt_client.connect("localhost", 1883, 60)
mqtt_client.loop_start()


### HTTP
@app.get("/sensor")
def get_sensor():
    if not machine_state["running"]:
        return {"value": 0}
    
    t = time.time() - start_time
    value = machine_state["speed"]*(50+30*math.sin(t))
    return{"value": round(value,2)}

@app.post("/command")
def send_command(cmd: dict):
    global machine_state
    if "running" in cmd:
        machine_state["running"] = cmd["running"]

    if "speed" in cmd:
        machine_state["speed"] = cmd["speed"]
    
    return {"status": "ok", "state": machine_state}


###WebSockets
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
        