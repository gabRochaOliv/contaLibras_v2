import os
import uuid
import requests
from dotenv import load_dotenv

load_dotenv()


def insert_cadastro(payload) -> str:
    """Gera o id no cliente (UUID) pra nao precisar de RETURNING/SELECT no
    Supabase — a tabela `cadastros` tem RLS com politica de INSERT apenas
    pra `anon`, entao a API ja sabe o id sem precisar ler a linha de volta."""
    supabase_url = os.environ["SUPABASE_URL"]
    supabase_key = os.environ["SUPABASE_ANON_KEY"]
    cadastro_id = str(uuid.uuid4())

    response = requests.post(
        f"{supabase_url}/rest/v1/cadastros",
        headers={
            "apikey": supabase_key,
            "Authorization": f"Bearer {supabase_key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        },
        json={
            "id": cadastro_id,
            "nome": payload.nome,
            "idade": payload.idade,
            "categoria": payload.categoria,
            "escolaridade": payload.escolaridade,
            "usa_libras": payload.usa_libras,
            "conhecimento_libras": payload.conhecimento_libras,
        },
        timeout=10,
    )
    response.raise_for_status()
    return cadastro_id


def insert_feedback(payload):
    respostas_json = [r.model_dump() for r in payload.respostas]
    supabase_url = os.environ["SUPABASE_URL"]
    supabase_key = os.environ["SUPABASE_ANON_KEY"]

    response = requests.post(
        f"{supabase_url}/rest/v1/feedbacks",
        headers={
            "apikey": supabase_key,
            "Authorization": f"Bearer {supabase_key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        },
        json={
            "nome": payload.nome,
            "idade": payload.idade,
            "categoria": payload.categoria,
            "escolaridade": payload.escolaridade,
            "usa_libras": payload.usa_libras,
            "conhecimento_libras": payload.conhecimento_libras,
            "comentario_gostou": payload.comentario_gostou,
            "comentario_melhorar": payload.comentario_melhorar,
            "comentario_sugestao": payload.comentario_sugestao,
            "respostas": respostas_json,
            "cadastro_id": payload.cadastro_id,
        },
        timeout=10,
    )
    response.raise_for_status()
