from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "vehicle-telemetry-api"


def test_vehicles():
    response = client.get("/vehicles")
    assert response.status_code == 200
    assert "vehicles" in response.json()


def test_telemetry():
    payload = {
        "vehicle_id": "vehicle-001",
        "speed": 65.5,
        "temperature": 88.2,
    }

    response = client.post("/telemetry", json=payload)

    assert response.status_code == 200
    assert response.json()["vehicle_id"] == "vehicle-001"


def test_metrics():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "http_requests_total" in response.text
    assert "http_request_duration_seconds" in response.text
