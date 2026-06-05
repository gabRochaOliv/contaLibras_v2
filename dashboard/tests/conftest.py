import pytest
import pandas as pd


@pytest.fixture
def sample_raw_df():
    """DataFrame simulando retorno bruto do banco — sem conexão real."""
    return pd.DataFrame([
        {
            "id": 1,
            "nome": "Ana",
            "idade": 22,
            "categoria": "Estudante",
            "respostas": [
                {"pergunta_id": 4, "valor": 5},
                {"pergunta_id": 5, "valor": 4},
            ],
            "criado_em": "2026-06-01T10:00:00+00:00",
        },
        {
            "id": 2,
            "nome": "João",
            "idade": 30,
            "categoria": "Professor",
            "respostas": [
                {"pergunta_id": 4, "valor": 3},
                {"pergunta_id": 5, "valor": 2},
            ],
            "criado_em": "2026-06-02T11:00:00+00:00",
        },
        {
            "id": 3,
            "nome": "Maria",
            "idade": 25,
            "categoria": "Intérprete",
            "respostas": [
                {"pergunta_id": 4, "valor": 4},
                {"pergunta_id": 30, "valor": 3},
                {"pergunta_id": 41, "valor": 5},
            ],
            "criado_em": "2026-06-03T12:00:00+00:00",
        },
    ])


@pytest.fixture
def sample_raw_df_vazio():
    """DataFrame vazio com as mesmas colunas — para testar empty state."""
    return pd.DataFrame(columns=["id", "nome", "idade", "categoria", "respostas", "criado_em"])
