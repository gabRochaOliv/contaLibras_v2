"""Mantem o projeto Supabase (free tier) acordado.

O free tier pausa o banco depois de ~7 dias sem atividade. Este script roda
no GitHub Actions a cada 3 dias e faz uma consulta trivial pelo mesmo caminho
(pooler -> Postgres) que o dashboard usa. Serve tambem de canario: se o pooler
voltar a dar erro de autenticacao, este job falha e o GitHub manda e-mail.
"""
import os
import sys
from urllib.parse import urlparse

import psycopg2

url = urlparse(os.environ["DATABASE_URL"])

try:
    conn = psycopg2.connect(
        host=url.hostname,
        port=url.port,
        dbname=url.path.lstrip("/"),
        user=url.username,
        password=url.password,
        sslmode="require",
        connect_timeout=15,
    )
except Exception as e:  # noqa: BLE001 - queremos falhar o job com contexto
    print(f"keep-alive FALHOU ao conectar no banco: {e!r}", file=sys.stderr)
    raise

try:
    with conn, conn.cursor() as cur:
        cur.execute("select now(), (select count(*) from feedbacks);")
        agora, total = cur.fetchone()
    print(f"OK - banco respondeu em {agora} | feedbacks: {total}")
finally:
    conn.close()
