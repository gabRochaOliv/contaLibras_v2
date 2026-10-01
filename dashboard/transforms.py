"""Transformações puras JSONB → DataFrame tabular — sem dependência de Streamlit."""
import pandas as pd

# ---------------------------------------------------------------------------
# Mapeamento de seções
# Critérios avaliativos atuais (q40-q47), definidos pelo orientador:
#   Usabilidade, IHC & Acessibilidade em Libras (q40-q43)
#   Qualidade Técnica & Engenharia de Software (q44-q47)
# Parte III por categoria (q20-q32): Bloco B (Professor), Bloco C
# (Especialista em Libras) e Bloco D (Contabilidade).
# q4-q19 pertencem ao questionário anterior (arquivado) e são mantidas para
# exibir as respostas já coletadas — ver QUESTIONARIOS abaixo.
# ---------------------------------------------------------------------------
SECAO_IHC_LIBRAS = "IHC & Acessibilidade em Libras"
SECAO_ENG_SOFTWARE = "Qualidade Técnica & Eng. de Software"

SECOES_IHC = {
    # Usabilidade, IHC & Acessibilidade em Libras — q40 a q43
    "q40": SECAO_IHC_LIBRAS,
    "q41": SECAO_IHC_LIBRAS,
    "q42": SECAO_IHC_LIBRAS,
    "q43": SECAO_IHC_LIBRAS,
    # Qualidade Técnica & Engenharia de Software — q44 a q47
    "q44": SECAO_ENG_SOFTWARE,
    "q45": SECAO_ENG_SOFTWARE,
    "q46": SECAO_ENG_SOFTWARE,
    "q47": SECAO_ENG_SOFTWARE,
    # Usabilidade — q4 a q8
    "q4": "Usabilidade",
    "q5": "Usabilidade",
    "q6": "Usabilidade",
    "q7": "Usabilidade",
    "q8": "Usabilidade",
    # Experiência do Usuário (UX) — q9 a q12
    "q9":  "Experiência (UX)",
    "q10": "Experiência (UX)",
    "q11": "Experiência (UX)",
    "q12": "Experiência (UX)",
    # Qualidade do Conteúdo — q13 a q15
    "q13": "Qualidade do Conteúdo",
    "q14": "Qualidade do Conteúdo",
    "q15": "Qualidade do Conteúdo",
    # Utilidade — q16 a q18
    "q16": "Utilidade",
    "q17": "Utilidade",
    "q18": "Utilidade",
    # Satisfação Geral — q19
    "q19": "Satisfação Geral",
    # Perguntas por Categoria — q20 a q32 (esparsas — nem todo respondente responde)
    "q20": "Perguntas por Categoria",
    "q21": "Perguntas por Categoria",
    "q22": "Perguntas por Categoria",
    "q23": "Perguntas por Categoria",
    "q24": "Perguntas por Categoria",
    "q25": "Perguntas por Categoria",
    "q26": "Perguntas por Categoria",
    "q27": "Perguntas por Categoria",
    "q28": "Perguntas por Categoria",
    "q29": "Perguntas por Categoria",
    "q30": "Perguntas por Categoria",
    "q31": "Perguntas por Categoria",
    "q32": "Perguntas por Categoria",
}


# ---------------------------------------------------------------------------
# Versões do questionário
#
# Todas as respostas ficam na mesma tabela `feedbacks` (coluna JSONB
# `respostas`). Cada versão usa uma faixa própria de IDs de pergunta, então a
# versão de uma resposta é identificada pelos IDs que ela contém — sem coluna
# extra no banco e sem risco de as respostas antigas se misturarem às novas.
# As perguntas por perfil (q20-q32) existem nas duas versões.
# ---------------------------------------------------------------------------
VERSAO_ATUAL = "atual"
VERSAO_ANTERIOR = "anterior"

PERGUNTAS_PERFIL = set(range(20, 33))

QUESTIONARIOS = {
    VERSAO_ATUAL: {
        "rotulo": "Atual — critérios do orientador",
        "ids": set(range(40, 48)),
        # (rótulo do KPI, seção) — as duas médias de destaque da versão
        "kpis": [
            ("IHC & Acessibilidade", SECAO_IHC_LIBRAS),
            ("Qualidade Técnica", SECAO_ENG_SOFTWARE),
        ],
    },
    VERSAO_ANTERIOR: {
        "rotulo": "Anterior (arquivado)",
        "ids": set(range(4, 20)),
        "kpis": [
            ("Usabilidade", "Usabilidade"),
            ("Utilidade", "Utilidade"),
        ],
    },
}


def _parse_respostas(x):
    """psycopg2 >= 2.9 já devolve JSONB como list de dicts; a conversão de
    string é só segurança defensiva."""
    import ast

    if isinstance(x, list):
        return x
    try:
        return ast.literal_eval(x)
    except Exception:
        return x


def classificar_versao(respostas):
    """Devolve a versão do questionário de uma resposta (pelos IDs usados).

    Retorna None quando a resposta não tem nenhuma pergunta geral (só perfil
    ou vazia) — caso que não deveria ocorrer, mas não pode quebrar a tela.
    """
    respostas = _parse_respostas(respostas)
    if not isinstance(respostas, list):
        return None
    ids = {r.get("pergunta_id") for r in respostas if isinstance(r, dict)}
    for versao, cfg in QUESTIONARIOS.items():
        if ids & cfg["ids"]:
            return versao
    return None


def colunas_da_versao(versao, colunas):
    """Colunas qN do DataFrame wide que pertencem à versão (gerais + perfil),
    em ordem numérica."""
    ids = QUESTIONARIOS[versao]["ids"] | PERGUNTAS_PERFIL
    qs = [c for c in colunas if c.startswith("q") and c[1:].isdigit() and int(c[1:]) in ids]
    return sorted(qs, key=lambda q: int(q[1:]))

# ---------------------------------------------------------------------------
# Mapeamento de labels curtos por questão (q4 a q32)
# ---------------------------------------------------------------------------
LABELS_QUESTOES = {
    # Critérios atuais
    "q40": "Clareza e Comunicação",
    "q41": "Fluidez de Navegação",
    "q42": "Design Visual e Consistência",
    "q43": "Prevenção de Erros",
    "q44": "Completude Funcional",
    "q45": "Segurança e Privacidade",
    "q46": "Desempenho e Resposta",
    "q47": "Estabilidade e Confiabilidade",
    # Usabilidade — rótulo curto para eixo X
    "q4": "Fácil de usar",
    "q5": "Navegação simples",
    "q6": "Aprende rápido",
    "q7": "Confiante ao usar",
    "q8": "Foi difícil usar",
    # Experiência (UX)
    "q9":  "Design agradável",
    "q10": "Telas organizadas",
    "q11": "Claro e compreensível",
    "q12": "Responde rapidamente",
    # Qualidade do Conteúdo
    "q13": "Vídeos ajudam",
    "q14": "Textos fáceis",
    "q15": "Conteúdo relevante",
    # Utilidade
    "q16": "Útil pra aprendizagem",
    "q17": "Usaria novamente",
    "q18": "Recomendaria",
    # Satisfação Geral
    "q19": "Satisfação geral",
    # Perguntas por Categoria (q20-q32 — esparsas)
    "q20": "Professor 1",
    "q21": "Professor 2",
    "q22": "Professor 3",
    "q23": "Professor 4",
    "q24": "Professor 5",
    "q25": "Libras 1",
    "q26": "Libras 2",
    "q27": "Libras 3",
    "q28": "Libras 4",
    "q29": "Contabilidade 1",
    "q30": "Contabilidade 2",
    "q31": "Contabilidade 3",
    "q32": "Contabilidade 4",
}

# Texto completo da pergunta — usado no hover dos gráficos
FULL_QUESTOES = {
    "q40": "Q40 (IHC — Clareza e Comunicação): Os conteúdos em Libras/Português, ícones e traduções são claros e compreensíveis?",
    "q41": "Q41 (IHC — Fluidez de Navegação): A transição entre os módulos e telas ocorre de forma simples e intuitiva?",
    "q42": "Q42 (IHC — Design Visual e Consistência): Cores, contraste, fontes e elementos visuais facilitam a leitura e a interação?",
    "q43": "Q43 (IHC — Prevenção de Erros): A interface minimiza ações acidentais e oferece instruções orientadoras?",
    "q44": "Q44 (Eng. Software — Completude Funcional): As ferramentas necessárias para a rotina financeira/educacional estão totalmente operacionais?",
    "q45": "Q45 (Eng. Software — Segurança e Privacidade): Sente segurança na apresentação dos dados na tela e na privacidade do seu acesso?",
    "q46": "Q46 (Eng. Software — Desempenho e Resposta): O carregamento dos vídeos, avatares e telas ocorre sem lentidão ou travamentos?",
    "q47": "Q47 (Eng. Software — Estabilidade e Confiabilidade): O sistema mantém-se firme e funcional durante toda a sua navegação?",
    "q4": "Q4 (Usabilidade): O aplicativo é fácil de usar.",
    "q5": "Q5 (Usabilidade): Navegar pelo aplicativo é simples.",
    "q6": "Q6 (Usabilidade): Eu aprendi a usar o aplicativo rapidamente.",
    "q7": "Q7 (Usabilidade): Eu me senti confiante ao usar o aplicativo.",
    "q8": "Q8 (Usabilidade): Foi difícil usar o aplicativo.",
    "q9":  "Q9 (UX): O design do aplicativo é agradável.",
    "q10": "Q10 (UX): As telas são bem organizadas.",
    "q11": "Q11 (UX): O aplicativo é claro e fácil de entender.",
    "q12": "Q12 (UX): O aplicativo responde rapidamente.",
    "q13": "Q13 (Conteúdo): Os vídeos ajudam na compreensão do conteúdo.",
    "q14": "Q14 (Conteúdo): Os textos são fáceis de entender.",
    "q15": "Q15 (Conteúdo): O conteúdo apresentado é relevante.",
    "q16": "Q16 (Utilidade): O aplicativo é útil para aprendizagem.",
    "q17": "Q17 (Utilidade): Eu utilizaria o aplicativo novamente.",
    "q18": "Q18 (Utilidade): Eu recomendaria o aplicativo para outras pessoas.",
    "q19": "Q19 (Satisfação Geral): Estou satisfeito com o aplicativo.",
    "q20": "Q20 (Bloco B — Professor): O aplicativo pode ser utilizado como recurso pedagógico.",
    "q21": "Q21 (Bloco B — Professor): O conteúdo é adequado para uso em sala de aula.",
    "q22": "Q22 (Bloco B — Professor): O aplicativo favorece a inclusão de estudantes surdos.",
    "q23": "Q23 (Bloco B — Professor): Eu utilizaria o aplicativo em atividades educacionais.",
    "q24": "Q24 (Bloco B — Professor): O aplicativo possui potencial educacional.",
    "q25": "Q25 (Bloco C — Especialista em Libras): Os sinais apresentados são adequados.",
    "q26": "Q26 (Bloco C — Especialista em Libras): A comunicação em Libras é clara.",
    "q27": "Q27 (Bloco C — Especialista em Libras): Os vídeos apresentam boa qualidade linguística.",
    "q28": "Q28 (Bloco C — Especialista em Libras): Os conceitos foram representados adequadamente em Libras.",
    "q29": "Q29 (Bloco D — Contabilidade): Os conceitos contábeis apresentados estão corretos.",
    "q30": "Q30 (Bloco D — Contabilidade): A terminologia utilizada é adequada.",
    "q31": "Q31 (Bloco D — Contabilidade): O conteúdo possui relevância para a área contábil.",
    "q32": "Q32 (Bloco D — Contabilidade): O aplicativo possui potencial para apoiar o ensino de contabilidade.",
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

    df["respostas"] = df["respostas"].apply(_parse_respostas)

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


FAIXAS_ETARIAS = ["< 18", "18–25", "26–35", "36–50", "> 50"]


def calcular_faixa_etaria(idade) -> str:
    """Converte idade exata para faixa etária categórica."""
    try:
        n = int(idade)
    except (TypeError, ValueError):
        return "Desconhecida"
    if n < 18:
        return "< 18"
    if n <= 25:
        return "18–25"
    if n <= 35:
        return "26–35"
    if n <= 50:
        return "36–50"
    return "> 50"


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
