import time
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.responses import Response
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Histogram,
    generate_latest,
)
from pydantic import BaseModel

app = FastAPI(
    title="Vehicle Telemetry API",
    version="1.0.0",
)

HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status_code"],
)

HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"],
)

VEHICLE_API_ERRORS_TOTAL = Counter(
    "vehicle_api_errors_total",
    "Total number of Vehicle API HTTP errors",
    ["endpoint", "status_code"],
)


class Telemetry(BaseModel):
    vehicle_id: str
    speed: float
    temperature: float


@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time.perf_counter()

    try:
        response = await call_next(request)
        status_code = response.status_code
    except Exception:
        status_code = 500

        HTTP_REQUESTS_TOTAL.labels(
            method=request.method,
            endpoint=request.url.path,
            status_code=status_code,
        ).inc()

        VEHICLE_API_ERRORS_TOTAL.labels(
            endpoint=request.url.path,
            status_code=status_code,
        ).inc()

        raise

    duration = time.perf_counter() - start_time

    route = request.scope.get("route")
    endpoint = getattr(route, "path", request.url.path)

    if endpoint != "/metrics":
        HTTP_REQUESTS_TOTAL.labels(
            method=request.method,
            endpoint=endpoint,
            status_code=status_code,
        ).inc()

        HTTP_REQUEST_DURATION_SECONDS.labels(
            method=request.method,
            endpoint=endpoint,
        ).observe(duration)

        if status_code >= 400:
            VEHICLE_API_ERRORS_TOTAL.labels(
                endpoint=endpoint,
                status_code=status_code,
            ).inc()

    return response


@app.get("/")
def root():
    return {
        "service": "vehicle-telemetry-api",
        "version": "1.0.0",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }


@app.get("/metrics", include_in_schema=False)
def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )


@app.get("/vehicles")
def vehicles():
    return {
        "vehicles": [
            {
                "vehicle_id": "vehicle-001",
                "status": "online",
            },
            {
                "vehicle_id": "vehicle-002",
                "status": "online",
            },
        ]
    }


@app.get("/vehicles/{vehicle_id}")
def vehicle(vehicle_id: str):
    return {
        "vehicle_id": vehicle_id,
        "status": "online",
    }


@app.post("/telemetry")
def telemetry(data: Telemetry):
    return {
        "message": "Telemetry received",
        "vehicle_id": data.vehicle_id,
        "speed": data.speed,
        "temperature": data.temperature,
        "received_at": datetime.now(timezone.utc),
    }
