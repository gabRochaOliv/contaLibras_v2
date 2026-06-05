import pytest


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_feedback_valid_payload(client, valid_payload, monkeypatch):
    monkeypatch.setattr("database.insert_feedback", lambda p: None)
    response = client.post("/feedback", json=valid_payload)
    assert response.status_code == 201
    assert "message" in response.json()


def test_feedback_missing_field(client):
    payload = {
        "idade": 22,
        "categoria": "Estudante",
        "respostas": [{"pergunta_id": 4, "valor": 5}],
        "timestamp": "2026-06-04T15:30:00Z",
    }
    response = client.post("/feedback", json=payload)
    assert response.status_code == 422


def test_feedback_invalid_valor(client):
    payload = {
        "nome": "Ana",
        "idade": 22,
        "categoria": "Estudante",
        "respostas": [{"pergunta_id": 4, "valor": "nao-e-int"}],
        "timestamp": "2026-06-04T15:30:00Z",
    }
    response = client.post("/feedback", json=payload)
    assert response.status_code == 422


def test_feedback_db_error(client, valid_payload, monkeypatch):
    def raise_error(p):
        raise Exception("db error")
    monkeypatch.setattr("database.insert_feedback", raise_error)
    response = client.post("/feedback", json=valid_payload)
    assert response.status_code == 500
