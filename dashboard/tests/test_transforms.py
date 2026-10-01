"""Testes unitários das transformações JSONB — estado RED (transforms.py ainda não existe)."""
import pytest


def test_pivot_respostas(sample_raw_df):
    from transforms import pivot_respostas
    df_wide = pivot_respostas(sample_raw_df)
    assert "q4" in df_wide.columns
    assert "q5" in df_wide.columns
    assert len(df_wide) == 3


def test_csv_colunas(sample_raw_df):
    from transforms import pivot_respostas
    df_wide = pivot_respostas(sample_raw_df)
    required = {"id", "nome", "idade", "categoria", "criado_em", "q4", "q5", "q30", "q41"}
    assert required.issubset(set(df_wide.columns))


def test_timeline(sample_raw_df):
    from transforms import build_timeline_df
    resultado = build_timeline_df(sample_raw_df)
    assert "data" in resultado.columns
    assert "respostas" in resultado.columns
    assert len(resultado) == 3


def test_pivot_respostas_vazio(sample_raw_df_vazio):
    from transforms import pivot_respostas
    resultado = pivot_respostas(sample_raw_df_vazio)
    assert len(resultado) == 0


# ---------------------------------------------------------------------------
# Versões do questionário
# ---------------------------------------------------------------------------

def test_classificar_versao_atual():
    from transforms import classificar_versao, VERSAO_ATUAL
    respostas = [{"pergunta_id": 40, "valor": 5}, {"pergunta_id": 21, "valor": 4}]
    assert classificar_versao(respostas) == VERSAO_ATUAL


def test_classificar_versao_anterior():
    from transforms import classificar_versao, VERSAO_ANTERIOR
    respostas = [{"pergunta_id": 4, "valor": 5}, {"pergunta_id": 19, "valor": 3}]
    assert classificar_versao(respostas) == VERSAO_ANTERIOR


def test_classificar_versao_aceita_string_do_banco():
    from transforms import classificar_versao, VERSAO_ATUAL
    assert classificar_versao("[{'pergunta_id': 47, 'valor': 2}]") == VERSAO_ATUAL


def test_classificar_versao_sem_perguntas_gerais():
    from transforms import classificar_versao
    # Só perguntas de perfil (existem nas duas versões) ou vazio: indefinido.
    assert classificar_versao([{"pergunta_id": 25, "valor": 4}]) is None
    assert classificar_versao([]) is None
    assert classificar_versao(None) is None


def test_versoes_nao_compartilham_ids():
    from transforms import QUESTIONARIOS, PERGUNTAS_PERFIL
    atual = QUESTIONARIOS["atual"]["ids"]
    anterior = QUESTIONARIOS["anterior"]["ids"]
    assert not atual & anterior
    assert not (atual | anterior) & PERGUNTAS_PERFIL


def test_colunas_da_versao_inclui_perfil_e_ordena():
    from transforms import colunas_da_versao
    colunas = ["id", "nome", "q47", "q4", "q21", "q40", "q19"]
    assert colunas_da_versao("atual", colunas) == ["q21", "q40", "q47"]
    assert colunas_da_versao("anterior", colunas) == ["q4", "q19", "q21"]


def test_todas_perguntas_da_versao_atual_tem_textos():
    from transforms import QUESTIONARIOS, SECOES_IHC, LABELS_QUESTOES, FULL_QUESTOES
    for pid in QUESTIONARIOS["atual"]["ids"]:
        q = f"q{pid}"
        assert q in SECOES_IHC and q in LABELS_QUESTOES and q in FULL_QUESTOES


def test_kpis_apontam_para_secoes_existentes():
    from transforms import QUESTIONARIOS, SECOES_IHC
    secoes = set(SECOES_IHC.values())
    for cfg in QUESTIONARIOS.values():
        for _rotulo, secao in cfg["kpis"]:
            assert secao in secoes
