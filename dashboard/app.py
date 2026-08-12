"""Dashboard ContaLibras — Entrypoint Streamlit.

Executar a partir da pasta dashboard/:
    DASHBOARD_PASSWORD=<senha> streamlit run app.py
"""
import hmac
import os
import sys
import traceback

import pandas as pd
import streamlit as st

from database import fetch_feedbacks, delete_feedbacks
from transforms import (
    pivot_respostas,
    SECOES_IHC,
    LABELS_QUESTOES,
    FULL_QUESTOES,
    calcular_faixa_etaria,
)
from charts import (
    chart_perfil_respondentes,
    chart_timeline,
    chart_avaliacao_geral,
    chart_likert_horizontal,
    chart_faixa_etaria,
    chart_pizza_pergunta,
    LIKERT_NOMES,
)

st.set_page_config(
    page_title="ContaLibras — Dashboard",
    page_icon="📊",
    layout="wide",
)

# CSS mínimo para cards de KPI
st.markdown(
    """
    <style>
    [data-testid="stMetric"] {
        background-color: #f8f9fb;
        border: 1px solid #e8eaed;
        border-radius: 10px;
        padding: 1rem 1.2rem;
    }
    [data-testid="stMetricValue"] { font-size: 1.9rem !important; }
    [data-testid="stMetricLabel"] { font-size: 0.78rem !important; color: #6b7280 !important; }
    </style>
    """,
    unsafe_allow_html=True,
)


# ---------------------------------------------------------------------------
# Autenticação por senha
# ---------------------------------------------------------------------------

def check_password() -> bool:
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

    _, col_center, _ = st.columns([1, 2, 1])
    with col_center:
        st.header("Acesso Restrito")
        st.text_input("Senha", type="password", key="password_input", on_change=_verify)
        st.button("Acessar Dashboard", on_click=_verify)
        if st.session_state.get("auth_error"):
            st.error("Senha incorreta. Tente novamente.")

    return False


if not check_password():
    st.stop()


# ---------------------------------------------------------------------------
# Carregar dados brutos (antes dos filtros — necessário para limites de data)
# ---------------------------------------------------------------------------

try:
    df_raw = fetch_feedbacks()
except Exception as e:
    print(f"[fetch_feedbacks] falha ao conectar/consultar o banco: {e!r}", file=sys.stderr)
    traceback.print_exc()
    st.error("Erro ao carregar os dados. Verifique a conexão com o banco e recarregue a página.")
    st.stop()

if len(df_raw) == 0:
    st.info("Nenhuma resposta coletada ainda. Os gráficos serão exibidos quando houver dados.")
    st.stop()

df_raw["_data"] = (
    pd.to_datetime(df_raw["criado_em"])
    .dt.tz_convert("America/Sao_Paulo")
    .dt.date
)
data_min = df_raw["_data"].min()
data_max = df_raw["_data"].max()


# ---------------------------------------------------------------------------
# Sidebar — filtros
# ---------------------------------------------------------------------------

st.sidebar.title("ContaLibras")
st.sidebar.caption("Dashboard de Feedback — Glossário de Contabilidade")
if st.sidebar.button("🔄 Atualizar dados agora"):
    fetch_feedbacks.clear()
    st.rerun()
st.sidebar.caption("Os dados ficam em cache por até 5 min — use o botão acima pra forçar a atualização.")
st.sidebar.divider()
st.sidebar.subheader("Filtros")

categorias_disponiveis = [
    "Todos", "Professor", "Estudante", "Intérprete de Libras",
    "Profissional da Contabilidade", "Outro",
]
categoria_selecionada = st.sidebar.selectbox("Categoria de Usuário", categorias_disponiveis)

periodo = st.sidebar.date_input(
    "Período de coleta",
    value=(data_min, data_max),
    min_value=data_min,
    max_value=data_max,
)

# Tratar caso em que o usuário ainda não concluiu a seleção do intervalo
if isinstance(periodo, (list, tuple)):
    data_inicio = periodo[0]
    data_fim = periodo[-1]
else:
    data_inicio = data_fim = periodo

st.sidebar.divider()

# Exportar CSV na sidebar (discreto)
st.sidebar.subheader("Exportar")


@st.cache_data
def _to_csv(df: pd.DataFrame) -> bytes:
    return df.to_csv(index=False).encode("utf-8")


# ---------------------------------------------------------------------------
# Aplicar filtros
# ---------------------------------------------------------------------------

mask = (df_raw["_data"] >= data_inicio) & (df_raw["_data"] <= data_fim)
df_raw_filtrado = df_raw[mask].copy()

if categoria_selecionada != "Todos":
    df_raw_filtrado = df_raw_filtrado[df_raw_filtrado["categoria"] == categoria_selecionada]

df_wide = pivot_respostas(df_raw_filtrado)

if len(df_wide) == 0:
    st.warning(
        "Nenhuma resposta encontrada para os filtros selecionados. "
        "Ajuste a categoria ou o período e tente novamente."
    )
    st.stop()

q_cols = [c for c in df_wide.columns if c.startswith("q")]

# Botão de export só aparece quando há dados
st.sidebar.download_button(
    label="Baixar CSV",
    data=_to_csv(df_wide),
    file_name="feedbacks_contalibras.csv",
    mime="text/csv",
)

st.sidebar.caption(f"{len(df_wide)} resposta(s) nos filtros selecionados.")


# ---------------------------------------------------------------------------
# Cabeçalho
# ---------------------------------------------------------------------------

st.title("Dashboard de Feedback — Glossário de Contabilidade")
st.caption(
    f"Dados coletados de {data_inicio.strftime('%d/%m/%Y')} a {data_fim.strftime('%d/%m/%Y')} "
    f"· {len(df_wide)} resposta(s)"
)
st.divider()


# ---------------------------------------------------------------------------
# KPIs
# ---------------------------------------------------------------------------

media_geral = df_wide[q_cols].mean().mean() if q_cols else None

qs_facilidade = [q for q in ("q5", "q8") if q in df_wide.columns]
media_facilidade = df_wide[qs_facilidade].mean().mean() if qs_facilidade else None

qs_utilidade = [q for q in ("q19", "q21") if q in df_wide.columns]
media_utilidade = df_wide[qs_utilidade].mean().mean() if qs_utilidade else None

if q_cols:
    total_resp_ind = df_wide[q_cols].count().sum()
    concordancias = (df_wide[q_cols] >= 4).sum().sum()
    taxa_concordancia = concordancias / total_resp_ind * 100 if total_resp_ind > 0 else 0.0
else:
    taxa_concordancia = None

kpi1, kpi2, kpi3, kpi4, kpi5 = st.columns(5)
kpi1.metric("Total de Respostas", len(df_wide))
kpi2.metric("Média Geral (1–5)", f"{media_geral:.2f}" if media_geral is not None else "—")
kpi3.metric("Facilidade de Uso", f"{media_facilidade:.2f}" if media_facilidade is not None else "—")
kpi4.metric("Utilidade p/ Aprendizado", f"{media_utilidade:.2f}" if media_utilidade is not None else "—")
kpi5.metric("Taxa de Concordância", f"{taxa_concordancia:.0f}%" if taxa_concordancia is not None else "—")

st.divider()


# ---------------------------------------------------------------------------
# 3 gráficos lado a lado
# ---------------------------------------------------------------------------

col_a, col_b, col_c = st.columns(3)

with col_a:
    st.plotly_chart(chart_perfil_respondentes(df_wide), use_container_width=True)

with col_b:
    st.plotly_chart(chart_timeline(df_raw_filtrado), use_container_width=True)

with col_c:
    st.plotly_chart(chart_avaliacao_geral(df_wide, q_cols), use_container_width=True)

st.divider()


# ---------------------------------------------------------------------------
# Distribuição Likert horizontal empilhada
# ---------------------------------------------------------------------------

st.subheader("Avaliação das Afirmações (Likert 1–5)")
st.caption(
    "Cada barra mostra a distribuição percentual das respostas (1 = Discordo totalmente → 5 = Concordo totalmente). "
    "O número à direita é a média da questão."
)

secoes_com_dados = list(dict.fromkeys(
    SECOES_IHC[q]
    for q in q_cols
    if q in SECOES_IHC
))

if secoes_com_dados:
    secao_selecionada = st.selectbox("Seção do questionário", secoes_com_dados)
    st.plotly_chart(
        chart_likert_horizontal(df_wide, secao_selecionada),
        use_container_width=True,
    )
else:
    st.info("Nenhuma questão Likert disponível para o filtro selecionado.")

st.divider()


# ---------------------------------------------------------------------------
# Distribuição por pergunta (pizza) — todos os respondentes
# ---------------------------------------------------------------------------

st.subheader("Distribuição de Respostas por Pergunta (Pizza)")
st.caption("Escolha uma pergunta e veja como todos os respondentes filtrados responderam a ela.")

if q_cols:
    opcoes_pergunta = sorted(q_cols, key=lambda q: int(q[1:]))
    pergunta_selecionada = st.selectbox(
        "Pergunta",
        opcoes_pergunta,
        format_func=lambda q: f"{q.upper()} — {LABELS_QUESTOES.get(q, q)}",
    )
    st.plotly_chart(
        chart_pizza_pergunta(df_wide, pergunta_selecionada),
        use_container_width=True,
    )
    st.caption(FULL_QUESTOES.get(pergunta_selecionada, ""))
else:
    st.info("Nenhuma questão disponível para o filtro selecionado.")

st.divider()


# ---------------------------------------------------------------------------
# Distribuição por faixa etária
# ---------------------------------------------------------------------------

st.subheader("Distribuição por Faixa Etária")
st.plotly_chart(chart_faixa_etaria(df_wide), use_container_width=True)

st.divider()


# ---------------------------------------------------------------------------
# Tabela de respondentes
# ---------------------------------------------------------------------------

st.subheader("Respondentes")

campos_demograficos = ["id", "escolaridade", "usa_libras", "conhecimento_libras"]
df_resp = df_wide[["id", "nome", "idade", "categoria", "criado_em"]].merge(
    df_raw_filtrado[campos_demograficos], on="id", how="left",
)
df_resp["faixa_etaria"] = df_resp["idade"].apply(calcular_faixa_etaria)
df_resp["criado_em"] = pd.to_datetime(df_resp["criado_em"]).dt.strftime("%d/%m/%Y")
df_resp["usa_libras"] = df_resp["usa_libras"].map({True: "Sim", False: "Não"})
df_resp = (
    df_resp
    .rename(columns={
        "nome": "Nome",
        "idade": "Idade",
        "faixa_etaria": "Faixa Etária",
        "categoria": "Categoria",
        "escolaridade": "Escolaridade",
        "usa_libras": "Usa Libras",
        "conhecimento_libras": "Conhecimento em Libras",
        "criado_em": "Data",
    })
    [["Nome", "Idade", "Faixa Etária", "Categoria", "Escolaridade",
      "Usa Libras", "Conhecimento em Libras", "Data"]]
    .reset_index(drop=True)
)

st.dataframe(df_resp, use_container_width=True, hide_index=True)
st.caption(f"{len(df_resp)} respondente(s) exibido(s).")

with st.expander("🗑️ Excluir registros"):
    st.caption(
        "Selecione respondentes para remover permanentemente do banco de dados "
        "(considera todos os registros, ignorando os filtros acima). Essa ação não pode ser desfeita."
    )
    opcoes_exclusao = {
        (
            f"#{row.id} — {row.nome} — {row.categoria} — "
            f"{pd.to_datetime(row.criado_em).strftime('%d/%m/%Y %H:%M')}"
        ): row.id
        for row in df_raw.sort_values("criado_em", ascending=False).itertuples()
    }
    selecionados = st.multiselect("Registros a excluir", list(opcoes_exclusao.keys()))

    if selecionados:
        ids_selecionados = [opcoes_exclusao[s] for s in selecionados]
        confirmar = st.checkbox(
            f"Confirmo a exclusão permanente de {len(ids_selecionados)} registro(s)."
        )
        if st.button("Excluir selecionados", type="primary", disabled=not confirmar):
            delete_feedbacks(ids_selecionados)
            fetch_feedbacks.clear()
            st.success("Registro(s) excluído(s) com sucesso.")
            st.rerun()

st.divider()


# ---------------------------------------------------------------------------
# Detalhe de um respondente — pergunta exata + resposta, na íntegra
# ---------------------------------------------------------------------------

st.subheader("Detalhe de um Respondente")
st.caption(
    "Mostra, pergunta por pergunta (texto exato do questionário), como uma pessoa específica respondeu."
)

df_wide_ordenado = df_wide.sort_values("criado_em", ascending=False)
opcoes_respondente = {
    (
        f"{row.nome} — {row.categoria} — "
        f"{pd.to_datetime(row.criado_em).strftime('%d/%m/%Y %H:%M')}"
    ): row.id
    for row in df_wide_ordenado.itertuples()
}

escolha = st.selectbox("Selecione um respondente", list(opcoes_respondente.keys()))
respondente_id = opcoes_respondente[escolha]
linha = df_wide[df_wide["id"] == respondente_id].iloc[0]
linha_raw = df_raw_filtrado[df_raw_filtrado["id"] == respondente_id].iloc[0]

perguntas_respondidas = sorted(
    (q for q in q_cols if pd.notna(linha[q])),
    key=lambda q: int(q[1:]),
)

secao_atual = None
for q in perguntas_respondidas:
    secao = SECOES_IHC.get(q, "Outras")
    if secao != secao_atual:
        st.markdown(f"**{secao}**")
        secao_atual = secao
    valor = int(linha[q])
    texto = FULL_QUESTOES.get(q, q)
    st.markdown(f"- {texto} → **{valor} — {LIKERT_NOMES[str(valor)]}**")

st.markdown("**Perguntas Abertas**")
_abertas = [
    ("O que mais gostou no aplicativo?", linha_raw.get("comentario_gostou")),
    ("O que pode ser melhorado?", linha_raw.get("comentario_melhorar")),
    ("Sugestão adicional?", linha_raw.get("comentario_sugestao")),
]
for pergunta, resposta in _abertas:
    resposta_fmt = resposta.strip() if isinstance(resposta, str) and resposta.strip() else "_(não respondido)_"
    st.markdown(f"- **{pergunta}** {resposta_fmt}")

st.divider()


# ---------------------------------------------------------------------------
# Comentários (perguntas abertas — opcionais)
# ---------------------------------------------------------------------------

st.subheader("Comentários (Perguntas Abertas)")

campos_comentarios = [
    "id", "comentario_gostou", "comentario_melhorar", "comentario_sugestao",
]
df_comentarios = df_wide[["id", "nome", "categoria"]].merge(
    df_raw_filtrado[campos_comentarios], on="id", how="left",
)
df_comentarios = df_comentarios[
    df_comentarios["comentario_gostou"].fillna("").str.strip().ne("")
    | df_comentarios["comentario_melhorar"].fillna("").str.strip().ne("")
    | df_comentarios["comentario_sugestao"].fillna("").str.strip().ne("")
]

if df_comentarios.empty:
    st.caption("Nenhum comentário deixado nos filtros selecionados.")
else:
    st.caption(f"{len(df_comentarios)} respondente(s) com comentário.")
    for _, linha_com in df_comentarios.iterrows():
        with st.expander(f"{linha_com['nome']} — {linha_com['categoria']}"):
            for rotulo, campo in [
                ("O que mais gostou", "comentario_gostou"),
                ("O que pode melhorar", "comentario_melhorar"),
                ("Sugestão adicional", "comentario_sugestao"),
            ]:
                valor = linha_com.get(campo)
                texto = valor.strip() if isinstance(valor, str) and valor.strip() else "_(não respondido)_"
                st.markdown(f"**{rotulo}:**")
                st.markdown(texto)
