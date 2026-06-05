"""Funções de criação de figuras Plotly — sem dependência de Streamlit.

Cada função recebe um DataFrame e retorna um objeto plotly.graph_objects.Figure.
A responsabilidade de chamar st.plotly_chart() é de app.py.
"""
import plotly.express as px
import pandas as pd

from transforms import SECOES_IHC, LABELS_QUESTOES, FULL_QUESTOES

# ---------------------------------------------------------------------------
# Constantes de cor
# ---------------------------------------------------------------------------

COLOR_MAP = {
    "Pessoa surda": "#1f77b4",
    "Professor":    "#ff7f0e",
    "Estudante":    "#2ca02c",
    "Intérprete":   "#d62728",
    "Outro":        "#9467bd",
}

# Sequência de 7 cores para as 7 seções no chart de médias por questão
COLOR_SEQUENCE_SECOES = [
    "#1f77b4",
    "#ff7f0e",
    "#2ca02c",
    "#d62728",
    "#9467bd",
    "#8c564b",
    "#e377c2",
]


# ---------------------------------------------------------------------------
# Chart 1: Médias Likert por Questão (D-07)
# ---------------------------------------------------------------------------

def chart_medias_por_questao(df_wide: pd.DataFrame):
    """Retorna figura Plotly com médias Likert por questão, agrupadas por seção.

    Args:
        df_wide: DataFrame wide com colunas qN (saída de pivot_respostas/build_wide_df).

    Returns:
        plotly.graph_objects.Figure com range_y=[1,5] e height=500.
    """
    # Selecionar colunas qN
    q_cols = [c for c in df_wide.columns if c.startswith("q")]

    # Calcular médias ignorando NaN (skipna=True por padrão no pandas)
    medias = df_wide[q_cols].mean().reset_index()
    medias.columns = ["questao", "media"]

    # Mapear label curto, texto completo (hover) e seção para cada questão
    medias["questao_label"] = medias["questao"].apply(
        lambda q: LABELS_QUESTOES.get(q, q)
    )
    medias["questao_completa"] = medias["questao"].apply(
        lambda q: FULL_QUESTOES.get(q, q)
    )
    medias["secao"] = medias["questao"].apply(
        lambda q: SECOES_IHC.get(q, "Outras")
    )

    fig = px.bar(
        medias,
        x="questao_label",
        y="media",
        color="secao",
        color_discrete_sequence=COLOR_SEQUENCE_SECOES,
        custom_data=["questao_completa", "questao"],
        labels={
            "questao_label": "",
            "media": "Média (1–5)",
            "secao": "Seção",
        },
        title="Médias Likert por Questão",
        range_y=[1, 5],
    )

    fig.update_traces(
        hovertemplate=(
            "<b>%{customdata[1]}</b><br>"
            "%{customdata[0]}<br>"
            "Média: <b>%{y:.2f}</b><extra></extra>"
        )
    )

    # Linha de referência horizontal em y=3 (ponto neutro da escala Likert)
    fig.add_hline(
        y=3,
        line_dash="dot",
        line_color="gray",
        annotation_text="Neutro (3)",
    )

    fig.update_layout(
        height=500,
        xaxis_tickangle=-45,
        xaxis_tickfont_size=11,
        margin={"b": 140},
    )

    return fig


# ---------------------------------------------------------------------------
# Chart 2: Comparativo por Categoria de Usuário (D-08)
# ---------------------------------------------------------------------------

def chart_comparativo_categoria(df_wide: pd.DataFrame):
    """Retorna figura Plotly com barras agrupadas por categoria e seção.

    Args:
        df_wide: DataFrame wide com colunas qN e coluna `categoria`.

    Returns:
        plotly.graph_objects.Figure com barmode='group' e height=450.
    """
    q_cols = [c for c in df_wide.columns if c.startswith("q")]

    # Construir DataFrame longo: (categoria, secao, media)
    records = []
    for q in q_cols:
        secao = SECOES_IHC.get(q, "Outras")
        # Agrupar por categoria e calcular média da questão (ignorar NaN)
        grp = df_wide.groupby("categoria")[q].mean(numeric_only=True)
        for categoria, media in grp.items():
            records.append({
                "categoria": categoria,
                "secao": secao,
                "media": media,
            })

    if not records:
        df_long = pd.DataFrame(columns=["categoria", "secao", "media"])
    else:
        df_long = pd.DataFrame(records)
        # Agregar por (categoria, secao) — média das médias das questões da seção
        df_long = (
            df_long
            .groupby(["categoria", "secao"], as_index=False)["media"]
            .mean()
        )

    fig = px.bar(
        df_long,
        x="secao",
        y="media",
        color="categoria",
        barmode="group",
        color_discrete_map=COLOR_MAP,
        labels={
            "secao": "Seção",
            "media": "Média (1–5)",
            "categoria": "Categoria",
        },
        title="Comparativo por Categoria de Usuário",
        range_y=[1, 5],
    )

    fig.add_hline(
        y=3,
        line_dash="dot",
        line_color="gray",
        annotation_text="Neutro (3)",
    )

    fig.update_layout(
        height=450,
        xaxis_tickangle=-30,
    )

    return fig


# ---------------------------------------------------------------------------
# Chart 3: Timeline de coleta por dia (D-09)
# ---------------------------------------------------------------------------

def chart_timeline(df: pd.DataFrame):
    """Retorna figura Plotly com volume de respostas por dia.

    Args:
        df: DataFrame bruto do banco (com campo `criado_em` TIMESTAMPTZ).

    Returns:
        plotly.graph_objects.Figure com markers=True e height=350.
    """
    df = df.copy()

    # Converter para fuso America/Sao_Paulo e extrair data
    df["data"] = (
        pd.to_datetime(df["criado_em"])
        .dt.tz_convert("America/Sao_Paulo")
        .dt.date
    )

    timeline = df.groupby("data").size().reset_index(name="respostas")

    fig = px.line(
        timeline,
        x="data",
        y="respostas",
        markers=True,
        labels={"data": "Data", "respostas": "Respostas"},
        title="Volume de Coleta por Dia",
        color_discrete_sequence=["#1f77b4"],
    )

    fig.update_layout(height=350)

    return fig
