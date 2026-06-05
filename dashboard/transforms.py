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
    # Usabilidade (SUS) — rótulo curto para eixo X
    "q4":  "Usar com frequência",
    "q5":  "Fácil de usar",
    "q6":  "Funcionalidades integradas",
    "q7":  "Aprende rápido",
    "q8":  "Navegação intuitiva",
    "q9":  "Confiante ao usar",
    "q10": "Sem dificuldades",
    # Experiência (UX)
    "q11": "Design agradável",
    "q12": "Telas bem organizadas",
    "q13": "Responde rapidamente",
    "q14": "Visualmente claro",
    # Qualidade do Conteúdo
    "q15": "Vídeos Libras ajudam",
    "q16": "Descrições claras",
    "q17": "Conteúdo relevante",
    "q18": "Informações confiáveis",
    # Aprendizado
    "q19": "Aprendizado de Libras",
    "q20": "Termos contábeis",
    "q21": "Ferramenta educacional",
    "q22": "Inclusão de surdos",
    # Aceitação (TAM)
    "q23": "Útil para Libras",
    "q24": "Acesso ao conhecimento",
    "q25": "Recomendaria",
    "q26": "Usaria novamente",
    # Avaliação Geral
    "q27": "Satisfação geral",
    "q28": "Atende expectativas",
    "q29": "Potencial de ensino",
    # Perguntas por Categoria (q30-q41 — esparsas)
    "q30": "Cat. específica 1a",
    "q31": "Cat. específica 1b",
    "q32": "Cat. específica 1c",
    "q33": "Professor 1",
    "q34": "Professor 2",
    "q35": "Professor 3",
    "q36": "Intérprete 1",
    "q37": "Intérprete 2",
    "q38": "Intérprete 3",
    "q39": "Surdo/Outro 1",
    "q40": "Surdo/Outro 2",
    "q41": "Surdo/Outro 3",
}

# Texto completo da pergunta — usado no hover dos gráficos
FULL_QUESTOES = {
    "q4":  "Q4 (SUS): Eu gostaria de utilizar este aplicativo com frequência.",
    "q5":  "Q5 (SUS): O aplicativo é fácil de usar.",
    "q6":  "Q6 (SUS): As funcionalidades do aplicativo são bem integradas.",
    "q7":  "Q7 (SUS): A maioria das pessoas conseguiria aprender a usar rapidamente.",
    "q8":  "Q8 (SUS): Navegar pelo aplicativo é simples e intuitivo.",
    "q9":  "Q9 (SUS): Eu me senti confiante ao utilizar o aplicativo.",
    "q10": "Q10 (SUS): Não encontrei dificuldades significativas ao usar.",
    "q11": "Q11 (UX): O design do aplicativo é agradável.",
    "q12": "Q12 (UX): A organização das telas facilita o uso.",
    "q13": "Q13 (UX): O aplicativo responde rapidamente às ações do usuário.",
    "q14": "Q14 (UX): O aplicativo é visualmente claro e compreensível.",
    "q15": "Q15 (Conteúdo): Os vídeos em Libras ajudam na compreensão dos termos.",
    "q16": "Q16 (Conteúdo): As descrições escritas são claras e fáceis de entender.",
    "q17": "Q17 (Conteúdo): O conteúdo apresentado é relevante para o aprendizado.",
    "q18": "Q18 (Conteúdo): O aplicativo apresenta informações confiáveis.",
    "q19": "Q19 (Aprendizado): O aplicativo contribuiu para meu aprendizado de Libras.",
    "q20": "Q20 (Aprendizado): Facilitou a compreensão de termos contábeis em Libras.",
    "q21": "Q21 (Aprendizado): Pode ser útil como ferramenta de apoio educacional.",
    "q22": "Q22 (Aprendizado): Pode ajudar na inclusão de pessoas surdas na área contábil.",
    "q23": "Q23 (TAM): O aplicativo é útil para o aprendizado de Libras.",
    "q24": "Q24 (TAM): Melhora o acesso ao conhecimento sobre contabilidade em Libras.",
    "q25": "Q25 (TAM): Eu recomendaria este aplicativo para outras pessoas.",
    "q26": "Q26 (TAM): Eu utilizaria este aplicativo novamente no futuro.",
    "q27": "Q27 (Geral): No geral, estou satisfeito com o aplicativo.",
    "q28": "Q28 (Geral): O aplicativo atende às expectativas dos usuários.",
    "q29": "Q29 (Geral): O aplicativo possui potencial para auxiliar no ensino de Libras.",
    "q30": "Q30 (Categoria): Pergunta específica — Estudante/Intérprete/Outro (1).",
    "q31": "Q31 (Categoria): Pergunta específica — Estudante/Intérprete/Outro (2).",
    "q32": "Q32 (Categoria): Pergunta específica — Estudante/Intérprete/Outro (3).",
    "q33": "Q33 (Categoria): Pergunta específica — Professor (1).",
    "q34": "Q34 (Categoria): Pergunta específica — Professor (2).",
    "q35": "Q35 (Categoria): Pergunta específica — Professor (3).",
    "q36": "Q36 (Categoria): Pergunta específica — Intérprete (1).",
    "q37": "Q37 (Categoria): Pergunta específica — Intérprete (2).",
    "q38": "Q38 (Categoria): Pergunta específica — Intérprete (3).",
    "q39": "Q39 (Categoria): Pergunta específica — Pessoa surda/Outro (1).",
    "q40": "Q40 (Categoria): Pergunta específica — Pessoa surda/Outro (2).",
    "q41": "Q41 (Categoria): Pergunta específica — Pessoa surda/Outro (3).",
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
