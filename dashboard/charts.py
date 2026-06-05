"""Funções de criação de figuras Plotly — sem dependência de Streamlit.

Cada função recebe um DataFrame e retorna um objeto plotly Figure.
A responsabilidade de chamar st.plotly_chart() é de app.py.
"""
import plotly.express as px
import plotly.graph_objects as go
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

COLOR_SEQUENCE_SECOES = [
    "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2",
]

LIKERT_CORES = {
    "1": "#d62728",
    "2": "#ff7f0e",
    "3": "#bdbdbd",
    "4": "#98df8a",
    "5": "#2ca02c",
}

LIKERT_NOMES = {
    "1": "Discordo totalmente",
    "2": "Discordo",
    "3": "Neutro",
    "4": "Concordo",
    "5": "Concordo totalmente",
}

# ---------------------------------------------------------------------------
# Novos gráficos — layout redesenhado
# ---------------------------------------------------------------------------

def chart_perfil_respondentes(df_wide: pd.DataFrame):
    """Barras verticais com contagem de respondentes por categoria."""
    contagem = df_wide["categoria"].value_counts().reset_index()
    contagem.columns = ["categoria", "count"]

    fig = px.bar(
        contagem,
        x="categoria",
        y="count",
        color="categoria",
        color_discrete_map=COLOR_MAP,
        labels={"categoria": "", "count": "Respondentes"},
        title="Perfil dos Respondentes",
        text="count",
    )
    fig.update_traces(textposition="outside")
    fig.update_layout(
        showlegend=False,
        height=300,
        margin=dict(t=50, b=40, l=40, r=10),
        yaxis=dict(showgrid=False),
    )
    return fig


def chart_avaliacao_geral(df_wide: pd.DataFrame, q_cols: list):
    """Donut: Excelente (5) / Boa (4) / Regular (3) / Ruim (1–2) baseado em q27."""
    if not q_cols:
        fig = go.Figure()
        fig.update_layout(title="Sem dados", height=300)
        return fig

    # q27 = "Satisfação geral" — medida mais direta de avaliação global
    if "q27" in df_wide.columns:
        serie = df_wide["q27"].dropna()
    else:
        serie = df_wide[q_cols].stack().dropna()

    if serie.empty:
        fig = go.Figure()
        fig.update_layout(title="Sem dados", height=300)
        return fig

    excelente = int((serie == 5).sum())
    boa       = int((serie == 4).sum())
    regular   = int((serie == 3).sum())
    ruim      = int(((serie == 1) | (serie == 2)).sum())
    media     = serie.mean()

    fig = go.Figure(go.Pie(
        labels=["Excelente (5)", "Boa (4)", "Regular (3)", "Ruim (1–2)"],
        values=[excelente, boa, regular, ruim],
        hole=0.55,
        marker_colors=["#2ca02c", "#98df8a", "#bdbdbd", "#d62728"],
        textinfo="percent",
        textfont_size=11,
        hovertemplate="%{label}: %{value} (%{percent})<extra></extra>",
        sort=False,
    ))
    fig.update_layout(
        title="Avaliação Geral",
        height=300,
        margin=dict(t=50, b=20, l=10, r=10),
        annotations=[
            dict(text=f"<b>{media:.2f}</b>", x=0.5, y=0.58, showarrow=False, font_size=20),
            dict(text="/ 5", x=0.5, y=0.42, showarrow=False, font_size=12, font_color="gray"),
        ],
        legend=dict(orientation="v", yanchor="middle", y=0.5, x=1.01, font_size=10),
    )
    return fig


def chart_likert_horizontal(df_wide: pd.DataFrame, secao: str):
    """Barras horizontais empilhadas (%) por nota Likert, média à direita."""
    q_secao = [q for q, s in SECOES_IHC.items() if s == secao and q in df_wide.columns]

    labels, medias = [], []
    notas_pcts = {n: [] for n in range(1, 6)}

    for q in q_secao:
        serie = df_wide[q].dropna()
        if serie.empty:
            continue
        total = len(serie)
        labels.append(LABELS_QUESTOES.get(q, q))
        medias.append(serie.mean())
        for nota in range(1, 6):
            notas_pcts[nota].append((serie == nota).sum() / total * 100)

    if not labels:
        fig = go.Figure()
        fig.update_layout(title="Sem dados para a seção selecionada", height=250)
        return fig

    fig = go.Figure()
    for nota in range(1, 6):
        pcts = notas_pcts[nota]
        fig.add_trace(go.Bar(
            name=LIKERT_NOMES[str(nota)],
            y=labels,
            x=pcts,
            orientation="h",
            marker_color=LIKERT_CORES[str(nota)],
            text=[f"{v:.0f}%" if v >= 8 else "" for v in pcts],
            textposition="inside",
            insidetextanchor="middle",
            textfont=dict(color="white", size=10),
            hovertemplate=f"{LIKERT_NOMES[str(nota)]}: %{{x:.1f}}%<extra></extra>",
        ))

    annotations = [
        dict(
            x=102, y=label,
            text=f"<b>{media:.2f}</b>",
            showarrow=False,
            xanchor="left",
            font=dict(size=11),
            xref="x", yref="y",
        )
        for label, media in zip(labels, medias)
    ]

    fig.update_layout(
        barmode="stack",
        title=f"Distribuição de Respostas — {secao}",
        height=max(300, len(labels) * 52 + 130),
        xaxis=dict(range=[0, 115], ticksuffix="%", showgrid=False, title=""),
        yaxis=dict(autorange="reversed", title=""),
        margin=dict(l=180, r=80, t=70, b=30),
        annotations=annotations,
        legend=dict(
            orientation="h", yanchor="bottom", y=1.02,
            xanchor="left", x=0, font_size=10,
        ),
    )
    return fig


def chart_faixa_etaria(df_wide: pd.DataFrame):
    """Barras horizontais com distribuição por faixa etária."""
    from transforms import calcular_faixa_etaria, FAIXAS_ETARIAS

    df = df_wide[["idade"]].copy()
    df["faixa"] = df["idade"].apply(calcular_faixa_etaria)
    contagem = (
        df["faixa"]
        .value_counts()
        .reindex(FAIXAS_ETARIAS, fill_value=0)
        .reset_index()
    )
    contagem.columns = ["faixa", "count"]

    fig = px.bar(
        contagem,
        x="count",
        y="faixa",
        orientation="h",
        labels={"faixa": "", "count": "Respondentes"},
        title="Distribuição por Faixa Etária",
        text="count",
        color_discrete_sequence=["#1f77b4"],
    )
    fig.update_traces(textposition="outside")
    fig.update_layout(
        height=300,
        yaxis=dict(autorange="reversed"),
        showlegend=False,
        margin=dict(l=70, r=60, t=50, b=30),
        xaxis=dict(showgrid=False),
    )
    return fig


# ---------------------------------------------------------------------------
# Gráficos existentes — mantidos para retrocompatibilidade com testes
# ---------------------------------------------------------------------------

def chart_distribuicao_por_questao(df_wide: pd.DataFrame, questao: str):
    """Distribuição de respostas Likert (1–5) para uma questão — barra vertical."""
    label = LABELS_QUESTOES.get(questao, questao)
    texto = FULL_QUESTOES.get(questao, questao)

    serie = df_wide[questao].dropna()
    if serie.empty:
        fig = px.bar(title=f"{questao} — sem respostas")
        fig.update_layout(height=220)
        return fig

    counts = serie.value_counts().reindex([1, 2, 3, 4, 5], fill_value=0).reset_index()
    counts.columns = ["valor", "count"]
    counts["valor"] = counts["valor"].astype(str)

    fig = px.bar(
        counts,
        x="valor", y="count",
        color="valor",
        color_discrete_map=LIKERT_CORES,
        labels={"valor": "Resposta (1–5)", "count": "Nº de respostas"},
        title=f"<b>{questao.upper()}</b> — {label}",
    )
    fig.update_traces(showlegend=False)
    fig.update_layout(height=220, margin={"t": 50, "b": 30, "l": 40, "r": 10}, title_font_size=13)
    fig.add_annotation(
        text=texto, xref="paper", yref="paper",
        x=0, y=-0.15, showarrow=False,
        font_size=10, font_color="gray", xanchor="left",
    )
    return fig


def chart_medias_por_questao(df_wide: pd.DataFrame):
    """Médias Likert por questão, agrupadas por seção — barras verticais."""
    q_cols = [c for c in df_wide.columns if c.startswith("q")]
    medias = df_wide[q_cols].mean().reset_index()
    medias.columns = ["questao", "media"]
    medias["questao_label"]    = medias["questao"].apply(lambda q: LABELS_QUESTOES.get(q, q))
    medias["questao_completa"] = medias["questao"].apply(lambda q: FULL_QUESTOES.get(q, q))
    medias["secao"]            = medias["questao"].apply(lambda q: SECOES_IHC.get(q, "Outras"))

    fig = px.bar(
        medias,
        x="questao_label", y="media",
        color="secao",
        color_discrete_sequence=COLOR_SEQUENCE_SECOES,
        custom_data=["questao_completa", "questao"],
        labels={"questao_label": "", "media": "Média (1–5)", "secao": "Seção"},
        title="Médias Likert por Questão",
        range_y=[1, 5],
    )
    fig.update_traces(hovertemplate=(
        "<b>%{customdata[1]}</b><br>%{customdata[0]}<br>Média: <b>%{y:.2f}</b><extra></extra>"
    ))
    fig.add_hline(y=3, line_dash="dot", line_color="gray", annotation_text="Neutro (3)")
    fig.update_layout(height=500, xaxis_tickangle=-45, xaxis_tickfont_size=11, margin={"b": 140})
    return fig


def chart_comparativo_categoria(df_wide: pd.DataFrame):
    """Barras agrupadas por categoria e seção do questionário."""
    q_cols = [c for c in df_wide.columns if c.startswith("q")]

    records = []
    for q in q_cols:
        secao = SECOES_IHC.get(q, "Outras")
        grp = df_wide.groupby("categoria")[q].mean(numeric_only=True)
        for categoria, media in grp.items():
            records.append({"categoria": categoria, "secao": secao, "media": media})

    if not records:
        df_long = pd.DataFrame(columns=["categoria", "secao", "media"])
    else:
        df_long = (
            pd.DataFrame(records)
            .groupby(["categoria", "secao"], as_index=False)["media"]
            .mean()
        )

    fig = px.bar(
        df_long,
        x="secao", y="media",
        color="categoria",
        barmode="group",
        color_discrete_map=COLOR_MAP,
        labels={"secao": "Seção", "media": "Média (1–5)", "categoria": "Categoria"},
        title="Comparativo por Categoria de Usuário",
        range_y=[1, 5],
    )
    fig.add_hline(y=3, line_dash="dot", line_color="gray", annotation_text="Neutro (3)")
    fig.update_layout(height=450, xaxis_tickangle=-30)
    return fig


def chart_timeline(df: pd.DataFrame):
    """Área com volume de respostas por dia."""
    df = df.copy()
    df["data"] = (
        pd.to_datetime(df["criado_em"])
        .dt.tz_convert("America/Sao_Paulo")
        .dt.date
    )
    timeline = df.groupby("data").size().reset_index(name="respostas")

    fig = px.area(
        timeline,
        x="data", y="respostas",
        labels={"data": "", "respostas": "Respostas"},
        title="Respostas ao Longo do Tempo",
        color_discrete_sequence=["#1f77b4"],
    )
    fig.update_layout(
        height=300,
        xaxis_tickformat="%d/%m",
        xaxis_tickangle=-30,
        margin=dict(t=50, b=40, l=50, r=10),
        yaxis=dict(showgrid=True, gridcolor="#f0f0f0"),
    )
    return fig
