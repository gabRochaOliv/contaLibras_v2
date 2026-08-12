import os
import psycopg2
import streamlit as st
import pandas as pd
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()


def get_connection():
    url = urlparse(os.environ["DATABASE_URL"])
    return psycopg2.connect(
        host=url.hostname,
        port=url.port,
        database=url.path.lstrip("/"),
        user=url.username,
        password=url.password,
        sslmode="require",
    )


def delete_feedbacks(ids: list[int]) -> None:
    """Remove feedbacks do banco pelos ids informados."""
    if not ids:
        return
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM feedbacks WHERE id = ANY(%s)", (ids,))
        conn.commit()
    finally:
        conn.close()


def delete_cadastros(ids: list[str]) -> None:
    """Remove cadastros do banco pelos ids (UUID) informados.

    Um cadastro que já tem feedback vinculado (cadastro_id) não pode ser
    apagado por causa da FK — deixa a exceção subir pra chamada avisar o
    usuário em vez de apagar o feedback junto silenciosamente.
    """
    if not ids:
        return
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM cadastros WHERE id = ANY(%s::uuid[])", (ids,))
        conn.commit()
    finally:
        conn.close()


@st.cache_data(ttl="5m")
def fetch_feedbacks() -> pd.DataFrame:
    """Busca todos os feedbacks do banco com cache de 5 minutos."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, nome, idade, categoria, escolaridade, usa_libras,
                       conhecimento_libras, comentario_gostou, comentario_melhorar,
                       comentario_sugestao, respostas, criado_em, cadastro_id
                FROM feedbacks
                ORDER BY criado_em DESC
                """
            )
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        return pd.DataFrame(rows, columns=cols)
    finally:
        conn.close()


@st.cache_data(ttl="5m")
def fetch_cadastros() -> pd.DataFrame:
    """Busca todos os cadastros (first access) do banco, respondido ou não."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, nome, idade, categoria, escolaridade, usa_libras,
                       conhecimento_libras, criado_em
                FROM cadastros
                ORDER BY criado_em DESC
                """
            )
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        return pd.DataFrame(rows, columns=cols)
    finally:
        conn.close()
