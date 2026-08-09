import pytest
import httpx
from main import app


@pytest.fixture(scope="module")
def client():
    with httpx.Client(app=app, base_url="http://test") as c:
        yield c


@pytest.fixture
def valid_payload():
    return {
        "nome": "Ana",
        "idade": 22,
        "categoria": "Estudante",
        "escolaridade": "Ensino Superior",
        "usa_libras": False,
        "conhecimento_libras": "Básico",
        "respostas": [
            {"pergunta_id": 4, "valor": 5},
            {"pergunta_id": 29, "valor": 4},
        ],
        "timestamp": "2026-06-04T15:30:00.000Z",
    }
