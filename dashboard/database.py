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


@st.cache_data(ttl="5m")
def fetch_feedbacks() -> pd.DataFrame:
    """Busca todos os feedbacks do banco com cache de 5 minutos."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, nome, idade, categoria, respostas, criado_em
                FROM feedbacks
                ORDER BY criado_em DESC
                """
            )
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        return pd.DataFrame(rows, columns=cols)
    finally:
        conn.close()
