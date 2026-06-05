"""Transformações puras JSONB → DataFrame tabular — sem dependência de Streamlit."""
import pandas as pd

# ---------------------------------------------------------------------------
# Mapeamento de seções IHC (q4 a q41)
# Verificado contra Feedback/questionario_IHC.md e 02-RESEARCH.md
# ---------------------------------------------------------------------------
SECOES_IHC = {
    # Usabilidade do Sistema (SUS) — q4 a q10
    "q4":  "Usabilidade (SUS)",
    "q5":  "Usabilidade (SUS)",
    "q6":  "Usabilidade (SUS)",
    "q7":  "Usabilidade (SUS)",
    "q8":  "Usabilidade (SUS)",
    "q9":  "Usabilidade (SUS)",
    "q10": "Usabilidade (SUS)",
    # Experiência do Usuário (UX) — q11 a q14
    "q11": "Experiência (UX)",
    "q12": "Experiência (UX)",
    "q13": "Experiência (UX)",
    "q14": "Experiência (UX)",
    # Qualidade do Conteúdo — q15 a q18
    "q15": "Qualidade do Conteúdo",
    "q16": "Qualidade do Conteúdo",
    "q17": "Qualidade do Conteúdo",
    "q18": "Qualidade do Conteúdo",
    # Aprendizado — q19 a q22
    "q19": "Aprendizado",
    "q20": "Aprendizado",
    "q21": "Aprendizado",
    "q22": "Aprendizado",
    # Aceitação da Tecnologia (TAM) — q23 a q26
    "q23": "Aceitação (TAM)",
    "q24": "Aceitação (TAM)",
    "q25": "Aceitação (TAM)",
    "q26": "Aceitação (TAM)",
    # Avaliação Geral — q27 a q29
    "q27": "Avaliação Geral",
    "q28": "Avaliação Geral",
    "q29": "Avaliação Geral",
    # Perguntas por Categoria — q30 a q41 (esparsas — nem todo respondente responde)
    "q30": "Perguntas por Categoria",
    "q31": "Perguntas por Categoria",
    "q32": "Perguntas por Categoria",
    "q33": "Perguntas por Categoria",
    "q34": "Perguntas por Categoria",
    "q35": "Perguntas por Categoria",
    "q36": "Perguntas por Categoria",
    "q37": "Perguntas por Categoria",
    "q38": "Perguntas por Categoria",
    "q39": "Perguntas por Categoria",
    "q40": "Perguntas por Categoria",
    "q41": "Perguntas por Categoria",
}

# ---------------------------------------------------------------------------
# Mapeamento de labels curtos por questão (q4 a q41)
# Fonte: Feedback/questionario_IHC.md (q4-q29) + 02-RESEARCH.md (q30-q41)
# ---------------------------------------------------------------------------
LABELS_QUESTOES = {
    # Usabilidade (SUS)
    "q4":  "q4 — Gostaria de usar com frequência",
    "q5":  "q5 — Fácil de usar",
    "q6":  "q6 — Funcionalidades bem integradas",
    "q7":  "q7 — Maioria aprenderia rápido",
    "q8":  "q8 — Navegação simples e intuitiva",
    "q9":  "q9 — Me senti confiante ao usar",
    "q10": "q10 — Sem dificuldades significativas",
    # Experiência (UX)
    "q11": "q11 — Design agradável",
    "q12": "q12 — Organização das telas facilita uso",
    "q13": "q13 — Responde rapidamente",
    "q14": "q14 — Visualmente claro",
    # Qualidade do Conteúdo
    "q15": "q15 — Vídeos em Libras ajudam",
    "q16": "q16 — Descrições escritas claras",
    "q17": "q17 — Conteúdo relevante",
    "q18": "q18 — Informações confiáveis",
    # Aprendizado
    "q19": "q19 — Contribuiu para aprendizado de Libras",
    "q20": "q20 — Facilitou compreensão de termos contábeis",
    "q21": "q21 — Útil como ferramenta educacional",
    "q22": "q22 — Pode ajudar na inclusão",
    # Aceitação (TAM)
    "q23": "q23 — Útil para aprendizado de Libras",
    "q24": "q24 — Melhora acesso ao conhecimento",
    "q25": "q25 — Recomendaria para outras pessoas",
    "q26": "q26 — Utilizaria novamente no futuro",
    # Avaliação Geral
    "q27": "q27 — Satisfeito com o aplicativo",
    "q28": "q28 — Atende às expectativas",
    "q29": "q29 — Potencial para auxiliar ensino de Libras",
    # Perguntas por Categoria (q30-q41 — esparsas; Estudante/Intérprete/Outro)
    "q30": "q30 — [Cat.] Pergunta específica 1 (Est./Int./Out.)",
    "q31": "q31 — [Cat.] Pergunta específica 2 (Est./Int./Out.)",
    "q32": "q32 — [Cat.] Pergunta específica 3 (Est./Int./Out.)",
    "q33": "q33 — [Cat.] Pergunta específica 1 (Professor)",
    "q34": "q34 — [Cat.] Pergunta específica 2 (Professor)",
    "q35": "q35 — [Cat.] Pergunta específica 3 (Professor)",
    "q36": "q36 — [Cat.] Pergunta específica 1 (Intérprete)",
    "q37": "q37 — [Cat.] Pergunta específica 2 (Intérprete)",
    "q38": "q38 — [Cat.] Pergunta específica 3 (Intérprete)",
    "q39": "q39 — [Cat.] Pergunta específica 1 (Surdo/Outro)",
    "q40": "q40 — [Cat.] Pergunta específica 2 (Surdo/Outro)",
    "q41": "q41 — [Cat.] Pergunta específica 3 (Surdo/Outro)",
}

# Colunas de identidade presentes no DataFrame bruto do banco
_INDEX_COLS = ["id", "nome", "idade", "categoria", "criado_em"]


def pivot_respostas(df: pd.DataFrame) -> pd.DataFrame:
    """Expande o campo JSONB `respostas` em colunas qN (q4..q41).

    Args:
        df: DataFrame bruto retornado pelo banco (campo `respostas` como list de dicts).

    Returns:
        DataFrame wide com colunas id, nome, idade, categoria, criado_em e qN para
        cada pergunta presente na amostra. Colunas q30..q41 serão NaN para
        respondentes que não pertencem à categoria correspondente (comportamento
        correto — esparso).
    """
    # Edge case: DataFrame vazio
    if len(df) == 0:
        return pd.DataFrame(columns=_INDEX_COLS)

    df = df.copy()

    # psycopg2 >= 2.9 retorna JSONB como list de dicts Python automaticamente.
    # O .apply abaixo é segurança defensiva para o caso de retornar como string.
    import ast

    def _parse(x):
        if isinstance(x, list):
            return x
        try:
            return ast.literal_eval(x)
        except Exception:
            return x

    df["respostas"] = df["respostas"].apply(_parse)

    # Expandir: uma linha por {pergunta_id, valor}
    df_exp = df.explode("respostas").reset_index(drop=True)
    df_exp["pergunta_id"] = df_exp["respostas"].apply(lambda x: x["pergunta_id"])
    df_exp["valor"] = df_exp["respostas"].apply(lambda x: x["valor"])

    # Pivot: uma coluna por pergunta_id
    # NÃO usar fillna(0) — manter NaN para perguntas de categoria não respondidas.
    df_wide = df_exp.pivot_table(
        index=_INDEX_COLS,
        columns="pergunta_id",
        values="valor",
        aggfunc="first",
    ).reset_index()

    # Renomear colunas numéricas para formato qN
    n_index = len(_INDEX_COLS)
    df_wide.columns = (
        list(_INDEX_COLS)
        + [f"q{int(c)}" for c in df_wide.columns[n_index:]]
    )
    df_wide.columns.name = None

    return df_wide


def build_wide_df(df: pd.DataFrame) -> pd.DataFrame:
    """Wrapper de pivot_respostas — retorna DataFrame wide com colunas qN.

    Mantido por clareza de API: app.py pode chamar build_wide_df() e
    testes podem chamar pivot_respostas() diretamente.
    """
    return pivot_respostas(df)


def build_timeline_df(df: pd.DataFrame) -> pd.DataFrame:
    """Agrupa respostas por data (fuso America/Sao_Paulo).

    Args:
        df: DataFrame bruto do banco (campo `criado_em` como TIMESTAMPTZ).

    Returns:
        DataFrame com colunas `data` (date) e `respostas` (int — contagem por dia).
    """
    df = df.copy()
    df["data"] = (
        pd.to_datetime(df["criado_em"])
        .dt.tz_convert("America/Sao_Paulo")
        .dt.date
    )
    return df.groupby("data").size().reset_index(name="respostas")
