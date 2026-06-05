"""Dashboard ContaLibras — Entrypoint Streamlit.

Executar a partir da pasta dashboard/:
    DASHBOARD_PASSWORD=<senha> streamlit run app.py
"""
import hmac
import os

import pandas as pd
import streamlit as st

from database import fetch_feedbacks
from transforms import pivot_respostas, build_timeline_df, SECOES_IHC, LABELS_QUESTOES, FULL_QUESTOES
from charts import chart_medias_por_questao, chart_comparativo_categoria, chart_timeline, chart_distribuicao_por_questao


# ---------------------------------------------------------------------------
# Autenticação por senha (D-04 / T-02-05)
# ---------------------------------------------------------------------------

def check_password() -> bool:
    """Retorna True se o usuário está autenticado.

    Usa hmac.compare_digest para resistência a timing attacks (D-04, T-02-05).
    Senha lida de DASHBOARD_PASSWORD env var — nunca hardcoded.
    """
    def _verify():
        entered = st.session_state.get("password_input", "")
        correct = os.environ.get("DASHBOARD_PASSWORD", "")
        if hmac.compare_digest(entered, correct):
            st.session_state["authenticated"] = True
        else:
            st.session_state["authenticated"] = False
            st.session_state["auth_error"] = True

    if st.session_state.get("authenticated"):
        return True

    # Layout centralizado — coluna central estreita para o formulário de login
    _, col_center, _ = st.columns([1, 2, 1])
    with col_center:
        st.header("Acesso Restrito")
        st.text_input(
            "Senha",
            type="password",
            key="password_input",
            on_change=_verify,
        )
        st.button("Acessar Dashboard", on_click=_verify)
        if st.session_state.get("auth_error"):
            st.error("Senha incorreta. Tente novamente.")

    return False


# ---------------------------------------------------------------------------
# Auth gate — bloqueia tudo abaixo até autenticação
# ---------------------------------------------------------------------------

if not check_password():
    st.stop()


# ---------------------------------------------------------------------------
# Sidebar — filtro por categoria de usuário (D-10)
# ---------------------------------------------------------------------------

st.sidebar.title("Filtros")

categorias_disponiveis = [
    "Todos",
    "Pessoa surda",
    "Professor",
    "Estudante",
    "Intérprete",
    "Outro",
]

categoria_selecionada = st.sidebar.selectbox(
    "Categoria de Usuário",
    categorias_disponiveis,
)

st.sidebar.caption("Filtro aplicado a todos os gráficos.")


# ---------------------------------------------------------------------------
# Carregar e transformar dados
# ---------------------------------------------------------------------------

try:
    df_raw = fetch_feedbacks()
except Exception:
    st.error(
        "Erro ao carregar os dados. Verifique a conexão com o banco de dados e recarregue a página."
    )
    st.stop()

# Verificar se há dados no banco antes de qualquer processamento
if len(df_raw) == 0:
    st.info("Nenhuma resposta coletada ainda. Os gráficos serão exibidos quando houver dados.")
    st.stop()

# Pivot JSONB → colunas qN
df_wide = pivot_respostas(df_raw)

# Aplicar filtro de categoria em memória (sem nova query ao banco)
if categoria_selecionada != "Todos":
    df_wide = df_wide[df_wide["categoria"] == categoria_selecionada]
    df_raw_filtrado = df_raw[df_raw["categoria"] == categoria_selecionada]
else:
    df_raw_filtrado = df_raw

# Empty state — filtro resultou em zero linhas
if len(df_wide) == 0:
    st.warning(
        "Nenhuma resposta encontrada para o filtro selecionado. "
        "Altere a categoria ou aguarde novas respostas."
    )
    st.stop()

# Identificar colunas qN presentes no DataFrame filtrado
q_cols = [c for c in df_wide.columns if c.startswith("q")]


# ---------------------------------------------------------------------------
# Título da página
# ---------------------------------------------------------------------------

st.title("ContaLibras — Dashboard de Análise")
st.caption("Dados do questionário IHC (questões Likert q4–q41)")

with st.expander("Ver perguntas do questionário"):
    secao_atual = None
    for q, texto in FULL_QUESTOES.items():
        secao = SECOES_IHC.get(q, "Outras")
        if secao != secao_atual:
            st.markdown(f"**{secao}**")
            secao_atual = secao
        st.markdown(f"- {texto}")


# ---------------------------------------------------------------------------
# Seção 1 — Resumo Geral (D-06)
# ---------------------------------------------------------------------------

st.header("Resumo Geral")

col1, col2, col3 = st.columns(3)

media_geral = df_wide[q_cols].mean().mean() if q_cols else None

# Melhor e pior seção (médias por seção)
if q_cols:
    medias_secao = {
        secao: df_wide[[c for c in q_cols if SECOES_IHC.get(c) == secao]].mean().mean()
        for secao in dict.fromkeys(SECOES_IHC.values())
        if any(SECOES_IHC.get(c) == secao for c in q_cols)
    }
    melhor_secao = max(medias_secao, key=medias_secao.get) if medias_secao else "—"
    pior_secao = min(medias_secao, key=medias_secao.get) if medias_secao else "—"
else:
    melhor_secao = pior_secao = "—"

col1.metric("Total de Respostas", len(df_wide))
col2.metric("Média Geral (1–5)", f"{media_geral:.2f}" if media_geral else "—")
col3.metric("Categorias Ativas", df_wide["categoria"].nunique())

col4, col5 = st.columns(2)
col4.metric("Seção com maior média", melhor_secao,
            f"{medias_secao.get(melhor_secao, 0):.2f}" if melhor_secao != "—" else None)
col5.metric("Seção com menor média", pior_secao,
            f"{medias_secao.get(pior_secao, 0):.2f}" if pior_secao != "—" else None)

st.divider()


# ---------------------------------------------------------------------------
# Seção 2 — Médias por Questão (D-07)
# ---------------------------------------------------------------------------

st.header("Médias por Questão (Likert 1–5)")
st.caption("Passe o mouse sobre as barras para ver o texto completo de cada pergunta. Escala de 1 (discordo totalmente) a 5 (concordo totalmente).")
fig1 = chart_medias_por_questao(df_wide)
st.plotly_chart(fig1, width="stretch")

st.subheader("Distribuição de respostas por pergunta")
st.caption("Selecione uma pergunta para ver quantas pessoas deram cada nota (1–5).")
questao_selecionada = st.selectbox(
    "Pergunta",
    options=q_cols,
    format_func=lambda q: f"{q.upper()} — {LABELS_QUESTOES.get(q, q)}",
)
fig_dist = chart_distribuicao_por_questao(df_wide, questao_selecionada)
st.plotly_chart(fig_dist, width="stretch")

st.divider()


# ---------------------------------------------------------------------------
# Seção 3 — Comparativo por Categoria de Usuário (D-08)
# ---------------------------------------------------------------------------

st.header("Comparativo por Categoria de Usuário")

fig2 = chart_comparativo_categoria(df_wide)
st.plotly_chart(fig2, width="stretch")
st.caption("Média por seção do questionário, agrupada por categoria de usuário.")

st.divider()


# ---------------------------------------------------------------------------
# Seção 4 — Timeline de Coleta (D-09)
# ---------------------------------------------------------------------------

st.header("Volume de Coleta por Período")

fig3 = chart_timeline(df_raw_filtrado)
st.plotly_chart(fig3, width="stretch")
st.caption("Número de respostas recebidas por dia durante o período de coleta.")

st.divider()


# ---------------------------------------------------------------------------
# Seção 5 — Respondentes
# ---------------------------------------------------------------------------

st.header("Respondentes")

df_respondentes = df_wide[["nome", "idade", "categoria", "criado_em"]].copy()
df_respondentes["criado_em"] = pd.to_datetime(df_respondentes["criado_em"]).dt.strftime("%d/%m/%Y %H:%M")
df_respondentes = df_respondentes.rename(columns={
    "nome": "Nome",
    "idade": "Idade",
    "categoria": "Categoria",
    "criado_em": "Data de resposta",
}).reset_index(drop=True)

st.dataframe(df_respondentes, use_container_width=True, hide_index=True)
st.caption(f"{len(df_respondentes)} respondente(s) exibido(s).")

st.divider()


# ---------------------------------------------------------------------------
# Seção 6 — Exportação CSV (D-11, D-12)
# ---------------------------------------------------------------------------

st.header("Exportar Dados")


@st.cache_data
def to_csv_bytes(df: pd.DataFrame) -> bytes:
    """Converte DataFrame para bytes CSV em UTF-8. Cache atualiza quando df muda."""
    return df.to_csv(index=False).encode("utf-8")


col_desc, col_btn = st.columns([3, 1])

col_desc.write(
    "Dados brutos com uma linha por resposta. "
    "Colunas: id, nome, idade, categoria, criado_em, q4–q41."
)

col_btn.download_button(
    label="Exportar CSV",
    data=to_csv_bytes(df_wide),
    file_name="feedbacks_contalibras.csv",
    mime="text/csv",
)
