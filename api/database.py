import os
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    return psycopg2.connect(os.environ["DATABASE_URL"])


def insert_feedback(payload):
    respostas_json = [r.model_dump() for r in payload.respostas]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO feedbacks (nome, idade, categoria, respostas)
                VALUES (%s, %s, %s, %s)
                """,
                (payload.nome, payload.idade, payload.categoria, Json(respostas_json)),
            )
        conn.commit()
    finally:
        conn.close()
