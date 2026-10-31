"""Geração de relatório Markdown completo da versão atual do questionário.

O arquivo gerado é pensado para ser lido por humanos ou colado numa IA para
análise qualitativa/quantitativa — por isso traz:
  - resumo com totais, médias e taxa de conclusão;
  - distribuição por categoria/faixa etária;
  - médias por pergunta e distribuição Likert percentual;
  - lista dos cadastrados que não responderam;
  - respostas detalhadas, pergunta por pergunta, de cada respondente,
    com texto completo da pergunta e rótulo Likert.

Sempre filtra pela versão `atual` (ignora o filtro da sidebar) — a versão
anterior fica no banco só para consulta histórica.
"""
from __future__ import annotations

from datetime import datetime

import pandas as pd

from transforms import (
    FULL_QUESTOES,
    INICIO_VERSAO_ATUAL,
    LABELS_QUESTOES,
    QUESTIONARIOS,
    SECOES_IHC,
    VERSAO_ATUAL,
    calcular_faixa_etaria,
    colunas_da_versao,
    pivot_respostas,
    versao_do_cadastro,
)

LIKERT_NOMES = {
    1: "Discordo totalmente",
    2: "Discordo",
    3: "Neutro",
    4: "Concordo",
    5: "Concordo totalmente",
}


def _fmt_media(valor) -> str:
    if valor is None or pd.isna(valor):
        return "—"
    return f"{valor:.2f}"


def _fmt_pct(parte: int, total: int) -> str:
    if total == 0:
        return "0%"
    return f"{parte / total * 100:.0f}%"


def _fmt_data(valor, com_hora: bool = False) -> str:
    if valor is None or pd.isna(valor):
        return "—"
    ts = pd.to_datetime(valor)
    fmt = "%d/%m/%Y %H:%M" if com_hora else "%d/%m/%Y"
    return ts.strftime(fmt)


def _fmt_texto_livre(valor) -> str:
    if isinstance(valor, str) and valor.strip():
        return valor.strip()
    return "_(não respondido)_"


def _ordenar_por_secao(colunas: list[str]) -> dict[str, list[str]]:
    """Agrupa colunas por seção preservando a ordem numérica dentro de cada seção."""
    por_secao: dict[str, list[str]] = {}
    for q in sorted(colunas, key=lambda c: int(c[1:])):
        secao = SECOES_IHC.get(q, "Outras")
        por_secao.setdefault(secao, []).append(q)
    return por_secao


def build_markdown_export(
    df_raw: pd.DataFrame,
    df_cadastros_raw: pd.DataFrame,
) -> str:
    """Monta o relatório Markdown completo da versão atual.

    Args:
        df_raw: feedbacks brutos do banco (com coluna `versao` já preenchida).
        df_cadastros_raw: cadastros brutos do banco (com coluna `_data`).

    Returns:
        string Markdown.
    """
    rotulo = QUESTIONARIOS[VERSAO_ATUAL]["rotulo"]

    df_feed = df_raw[df_raw["versao"] == VERSAO_ATUAL].copy() if "versao" in df_raw.columns else df_raw.copy()
    df_feed = df_feed.sort_values("criado_em")

    if "_data" in df_cadastros_raw.columns:
        df_cad = df_cadastros_raw[
            df_cadastros_raw["_data"].apply(versao_do_cadastro) == VERSAO_ATUAL
        ].copy()
    else:
        df_cad = df_cadastros_raw.copy()
    df_cad = df_cad.sort_values("criado_em")

    df_wide = pivot_respostas(df_feed)
    q_cols = colunas_da_versao(VERSAO_ATUAL, df_wide.columns) if len(df_wide) > 0 else []

    gerado_em = datetime.now().strftime("%d/%m/%Y %H:%M")
    inicio_atual = INICIO_VERSAO_ATUAL.strftime("%d/%m/%Y")

    linhas: list[str] = []
    linhas.append("# ContaLibras — Relatório Completo da Avaliação")
    linhas.append("")
    linhas.append(f"- **Questionário:** {rotulo}")
    linhas.append(f"- **Em vigor desde:** {inicio_atual}")
    linhas.append(f"- **Gerado em:** {gerado_em}")
    linhas.append("")
    linhas.append(
        "> Este relatório traz todos os dados coletados pela versão atual do "
        "questionário — cadastros, respostas, comentários e estatísticas. "
        "Respostas da versão anterior do questionário não estão incluídas "
        "(ficam arquivadas no banco para consulta histórica)."
    )
    linhas.append("")

    linhas.append("---")
    linhas.append("")

    # -----------------------------------------------------------------------
    # 1. Resumo Geral
    # -----------------------------------------------------------------------
    total_cadastros = len(df_cad)
    ids_responderam = (
        set(df_feed["cadastro_id"].dropna().astype(str))
        if "cadastro_id" in df_feed.columns
        else set()
    )
    cadastros_responderam = (
        df_cad["id"].astype(str).isin(ids_responderam).sum()
        if total_cadastros > 0
        else 0
    )
    cadastros_sem_resposta = total_cadastros - cadastros_responderam
    taxa_conclusao = (
        cadastros_responderam / total_cadastros * 100 if total_cadastros > 0 else 0
    )

    total_respostas = len(df_wide)
    media_geral = df_wide[q_cols].mean().mean() if q_cols and total_respostas > 0 else None

    kpis_versao = QUESTIONARIOS[VERSAO_ATUAL]["kpis"]
    medias_destaque: list[tuple[str, float | None]] = []
    for rotulo_kpi, secao in kpis_versao:
        qs_secao = [q for q in q_cols if SECOES_IHC.get(q) == secao]
        media = df_wide[qs_secao].mean().mean() if qs_secao and total_respostas > 0 else None
        medias_destaque.append((rotulo_kpi, media))

    if q_cols and total_respostas > 0:
        total_resp_ind = int(df_wide[q_cols].count().sum())
        concordancias = int((df_wide[q_cols] >= 4).sum().sum())
        taxa_concordancia = (
            concordancias / total_resp_ind * 100 if total_resp_ind > 0 else 0
        )
    else:
        taxa_concordancia = None

    linhas.append("## 1. Resumo Geral")
    linhas.append("")
    linhas.append(f"- **Total de cadastros no app:** {total_cadastros}")
    linhas.append(
        f"- **Cadastros que responderam o questionário:** {int(cadastros_responderam)} "
        f"({taxa_conclusao:.0f}% de taxa de conclusão)"
    )
    linhas.append(f"- **Cadastros que não responderam:** {int(cadastros_sem_resposta)}")
    linhas.append(f"- **Total de respostas ao questionário:** {total_respostas}")
    linhas.append(f"- **Média geral (1–5):** {_fmt_media(media_geral)}")
    for rotulo_kpi, media in medias_destaque:
        linhas.append(f"- **{rotulo_kpi}:** {_fmt_media(media)}")
    if taxa_concordancia is not None:
        linhas.append(
            f"- **Taxa de concordância (respostas ≥ 4):** {taxa_concordancia:.0f}%"
        )
    linhas.append("")

    # -----------------------------------------------------------------------
    # 2. Distribuição por Categoria
    # -----------------------------------------------------------------------
    linhas.append("## 2. Distribuição por Categoria")
    linhas.append("")

    linhas.append("### Cadastros")
    if total_cadastros == 0:
        linhas.append("- _(nenhum cadastro na versão atual)_")
    else:
        for cat, qtd in df_cad["categoria"].value_counts().items():
            linhas.append(f"- {cat}: {int(qtd)} ({_fmt_pct(int(qtd), total_cadastros)})")
    linhas.append("")

    linhas.append("### Respondentes")
    if total_respostas == 0:
        linhas.append("- _(nenhuma resposta na versão atual)_")
    else:
        for cat, qtd in df_wide["categoria"].value_counts().items():
            linhas.append(
                f"- {cat}: {int(qtd)} ({_fmt_pct(int(qtd), total_respostas)})"
            )
    linhas.append("")

    # -----------------------------------------------------------------------
    # 3. Faixa Etária dos respondentes
    # -----------------------------------------------------------------------
    linhas.append("## 3. Distribuição por Faixa Etária (respondentes)")
    linhas.append("")
    if total_respostas == 0:
        linhas.append("- _(nenhuma resposta na versão atual)_")
    else:
        faixas = df_wide["idade"].apply(calcular_faixa_etaria).value_counts()
        ordem_faixas = ["< 18", "18–25", "26–35", "36–50", "> 50", "Desconhecida"]
        for faixa in ordem_faixas:
            if faixa in faixas:
                qtd = int(faixas[faixa])
                linhas.append(f"- {faixa}: {qtd} ({_fmt_pct(qtd, total_respostas)})")
    linhas.append("")

    # -----------------------------------------------------------------------
    # 4. Médias por Pergunta (por seção)
    # -----------------------------------------------------------------------
    linhas.append("## 4. Médias por Pergunta")
    linhas.append("")

    if not q_cols or total_respostas == 0:
        linhas.append("_(nenhuma resposta para calcular médias)_")
        linhas.append("")
    else:
        por_secao = _ordenar_por_secao(q_cols)
        for secao, qs in por_secao.items():
            linhas.append(f"### {secao}")
            for q in qs:
                media = df_wide[q].mean()
                n = int(df_wide[q].count())
                label = LABELS_QUESTOES.get(q, q)
                linhas.append(
                    f"- **{q.upper()} — {label}**: {_fmt_media(media)} "
                    f"(n = {n})"
                )
            linhas.append("")

    # -----------------------------------------------------------------------
    # 5. Distribuição Likert por Pergunta
    # -----------------------------------------------------------------------
    linhas.append("## 5. Distribuição Likert por Pergunta")
    linhas.append("")
    linhas.append(
        "Para cada pergunta, quantas pessoas marcaram cada valor "
        "(1 = Discordo totalmente → 5 = Concordo totalmente)."
    )
    linhas.append("")

    if not q_cols or total_respostas == 0:
        linhas.append("_(nenhuma resposta para calcular distribuições)_")
        linhas.append("")
    else:
        por_secao = _ordenar_por_secao(q_cols)
        for secao, qs in por_secao.items():
            linhas.append(f"### {secao}")
            for q in qs:
                serie = df_wide[q].dropna()
                n = len(serie)
                label = LABELS_QUESTOES.get(q, q)
                linhas.append(f"- **{q.upper()} — {label}** (n = {n})")
                if n == 0:
                    linhas.append("  - _(sem respostas)_")
                    continue
                for valor in (1, 2, 3, 4, 5):
                    qtd = int((serie == valor).sum())
                    linhas.append(
                        f"  - {valor} ({LIKERT_NOMES[valor]}): "
                        f"{qtd} ({_fmt_pct(qtd, n)})"
                    )
            linhas.append("")

    # -----------------------------------------------------------------------
    # 6. Comentários (perguntas abertas) agregados
    # -----------------------------------------------------------------------
    linhas.append("## 6. Perguntas Abertas (todos os comentários)")
    linhas.append("")

    comentarios_campos = [
        ("O que mais gostou no aplicativo", "comentario_gostou"),
        ("O que pode ser melhorado", "comentario_melhorar"),
        ("Sugestão adicional", "comentario_sugestao"),
    ]
    tem_algum_comentario = False
    for rotulo_c, campo in comentarios_campos:
        linhas.append(f"### {rotulo_c}")
        if campo not in df_feed.columns or len(df_feed) == 0:
            linhas.append("- _(nenhuma resposta)_")
            linhas.append("")
            continue
        comentarios = df_feed[["nome", "categoria", campo]].copy()
        comentarios = comentarios[
            comentarios[campo].fillna("").astype(str).str.strip().ne("")
        ]
        if comentarios.empty:
            linhas.append("- _(ninguém comentou)_")
        else:
            tem_algum_comentario = True
            for _, linha in comentarios.iterrows():
                nome = linha["nome"] or "—"
                cat = linha["categoria"] or "—"
                texto = str(linha[campo]).strip()
                linhas.append(f"- **{nome}** ({cat}): {texto}")
        linhas.append("")
    if not tem_algum_comentario and total_respostas > 0:
        linhas.append("_Nenhum respondente deixou comentário em nenhuma pergunta aberta._")
        linhas.append("")

    # -----------------------------------------------------------------------
    # 7. Cadastrados que NÃO responderam
    # -----------------------------------------------------------------------
    linhas.append("## 7. Cadastrados que NÃO responderam o questionário")
    linhas.append("")
    if total_cadastros == 0:
        linhas.append("_(nenhum cadastro na versão atual)_")
    else:
        df_sem = df_cad[~df_cad["id"].astype(str).isin(ids_responderam)]
        df_sem = df_sem.sort_values("criado_em", ascending=False)
        if df_sem.empty:
            linhas.append("Todos os cadastrados também responderam o questionário.")
        else:
            for row in df_sem.itertuples():
                nome = getattr(row, "nome", None) or "—"
                cat = getattr(row, "categoria", None) or "—"
                data = _fmt_data(getattr(row, "criado_em"), com_hora=True)
                linhas.append(f"- {nome} — {cat} — cadastrado em {data}")
    linhas.append("")

    # -----------------------------------------------------------------------
    # 8. Respostas detalhadas, respondente por respondente
    # -----------------------------------------------------------------------
    linhas.append("## 8. Respostas Detalhadas por Respondente")
    linhas.append("")

    if total_respostas == 0:
        linhas.append("_(nenhuma resposta na versão atual)_")
        linhas.append("")
    else:
        # Precisamos combinar df_wide (perguntas pivotadas) com df_feed
        # (demografia completa + comentários).
        df_wide_ord = df_wide.sort_values("criado_em")
        for idx, (_, resp) in enumerate(df_wide_ord.iterrows(), start=1):
            resp_id = resp["id"]
            feed_rows = df_feed[df_feed["id"] == resp_id]
            feed = feed_rows.iloc[0] if len(feed_rows) > 0 else None

            nome = resp.get("nome") or "—"
            cat = resp.get("categoria") or "—"
            idade = resp.get("idade")
            faixa = calcular_faixa_etaria(idade)
            escolaridade = (feed["escolaridade"] if feed is not None else None) or "—"
            usa = feed["usa_libras"] if feed is not None else None
            if usa is None or (isinstance(usa, float) and pd.isna(usa)):
                usa_txt = "—"
            else:
                usa_txt = "Sim" if bool(usa) else "Não"
            conhecimento = (
                (feed["conhecimento_libras"] if feed is not None else None) or "—"
            )
            quando = _fmt_data(resp.get("criado_em"), com_hora=True)

            linhas.append(f"### Respondente {idx} — {nome}")
            linhas.append("")
            linhas.append(f"- **Categoria:** {cat}")
            linhas.append(f"- **Idade:** {idade if pd.notna(idade) else '—'} ({faixa})")
            linhas.append(f"- **Escolaridade:** {escolaridade}")
            linhas.append(f"- **Usa Libras:** {usa_txt}")
            linhas.append(f"- **Conhecimento em Libras:** {conhecimento}")
            linhas.append(f"- **Respondeu em:** {quando}")
            linhas.append("")

            qs_respondidos = [q for q in q_cols if pd.notna(resp.get(q))]
            if not qs_respondidos:
                linhas.append("_Nenhuma pergunta Likert respondida._")
                linhas.append("")
            else:
                por_secao = _ordenar_por_secao(qs_respondidos)
                for secao, qs in por_secao.items():
                    linhas.append(f"**{secao}**")
                    linhas.append("")
                    for q in qs:
                        valor = int(resp[q])
                        label = LABELS_QUESTOES.get(q, q)
                        texto = FULL_QUESTOES.get(q, q)
                        linhas.append(f"- *{q.upper()} — {label}*")
                        linhas.append(f"  - Pergunta: {texto}")
                        linhas.append(
                            f"  - Resposta: **{valor} — {LIKERT_NOMES[valor]}**"
                        )
                    linhas.append("")

            linhas.append("**Perguntas Abertas**")
            linhas.append("")
            for rotulo_c, campo in comentarios_campos:
                valor_c = feed[campo] if feed is not None else None
                linhas.append(f"- *{rotulo_c}:* {_fmt_texto_livre(valor_c)}")
            linhas.append("")
            linhas.append("---")
            linhas.append("")

    return "\n".join(linhas).rstrip() + "\n"
