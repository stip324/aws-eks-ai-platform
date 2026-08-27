from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime, timezone

app = FastAPI(
    title="Vehicle Telemetry API",
    version="1.0.0"
)


class Telemetry(BaseModel):
    vehicle_id: str
    speed: float
    temperature: float


@app.get("/")
def root():
    return {
        "service": "vehicle-telemetry-api",
        "version": "1.0.0"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/vehicles")
def vehicles():
    return {
        "vehicles": [
            {
                "vehicle_id": "vehicle-001",
                "status": "online"
            },
            {
                "vehicle_id": "vehicle-002",
                "status": "online"
            }
        ]
    }


@app.get("/vehicles/{vehicle_id}")
def vehicle(vehicle_id: str):
    return {
        "vehicle_id": vehicle_id,
        "status": "online"
    }


@app.post("/telemetry")
def telemetry(data: Telemetry):
    return {
        "message": "Telemetry received",
        "vehicle_id": data.vehicle_id,
        "speed": data.speed,
        "temperature": data.temperature,
        "received_at": datetime.now(timezone.utc)
    }
