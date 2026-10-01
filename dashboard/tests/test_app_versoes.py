"""Teste de ponta a ponta do dashboard (Streamlit AppTest) com dados simulados
das duas versões do questionário — sem conexão com o banco."""
from pathlib import Path
from unittest.mock import patch

import pandas as pd
import pytest
from streamlit.testing.v1 import AppTest

APP = str(Path(__file__).resolve().parent.parent / "app.py")


def _feedback(id_, nome, categoria, respostas, criado_em, cadastro_id=None):
    return {
        "id": id_, "nome": nome, "idade": 25, "categoria": categoria,
        "escolaridade": "Ensino Superior", "usa_libras": True,
        "conhecimento_libras": "Básico", "comentario_gostou": "",
        "comentario_melhorar": "", "comentario_sugestao": "",
        "respostas": respostas, "criado_em": pd.Timestamp(criado_em),
        "cadastro_id": cadastro_id,
    }


def _anteriores():
    return [
        _feedback(1, "Ana", "Estudante",
                  [{"pergunta_id": i, "valor": 4} for i in range(4, 20)],
                  "2026-09-01T10:00:00+00:00", "c1"),
        _feedback(2, "Bia", "Professor",
                  [{"pergunta_id": i, "valor": 2} for i in range(4, 20)]
                  + [{"pergunta_id": 20, "valor": 5}],
                  "2026-09-02T10:00:00+00:00", "c2"),
    ]


def _atuais():
    return [
        _feedback(3, "Caio", "Estudante",
                  [{"pergunta_id": i, "valor": 5} for i in range(40, 48)],
                  "2026-10-01T10:00:00+00:00", "c3"),
        _feedback(4, "Duda", "Professor",
                  [{"pergunta_id": i, "valor": 3} for i in range(40, 48)]
                  + [{"pergunta_id": 21, "valor": 4}],
                  "2026-10-01T12:00:00+00:00", "c4"),
    ]


def _cadastros(ids, criado_em="2026-09-01T09:00:00+00:00"):
    return pd.DataFrame([
        {"id": i, "nome": f"Pessoa {i}", "idade": 25, "categoria": "Estudante",
         "escolaridade": "Ensino Superior", "usa_libras": True,
         "conhecimento_libras": "Básico",
         "criado_em": pd.Timestamp(criado_em)}
        for i in ids
    ])


def _cadastros_misturados():
    """c1/c2 antes da troca do questionário; c3/c4/c5 depois (c5 sem resposta)."""
    return pd.concat([
        _cadastros(["c1", "c2"], "2026-09-01T09:00:00+00:00"),
        _cadastros(["c3", "c4", "c5"], "2026-10-01T09:00:00+00:00"),
    ], ignore_index=True)


def _run(feedbacks, cadastros, versao=None):
    fake_fetch = lambda: pd.DataFrame(feedbacks)  # noqa: E731
    fake_cad = lambda: cadastros  # noqa: E731
    fake_fetch.clear = fake_cad.clear = lambda: None
    with patch("database.fetch_feedbacks", fake_fetch), \
         patch("database.fetch_cadastros", fake_cad):
        at = AppTest.from_file(APP, default_timeout=30)
        at.session_state["authenticated"] = True
        at.run()
        if versao is not None:
            at.sidebar.radio[0].set_value(versao).run()
    assert not at.exception, at.exception
    return at


def _metric(at, label):
    return next(m.value for m in at.metric if m.label == label)


def _textos(at):
    return " ".join(
        [m.value for m in at.markdown] + [c.value for c in at.caption]
        + [i.value for i in at.info] + [w.value for w in at.warning]
    )


def test_versao_atual_e_o_padrao_e_mostra_so_respostas_novas():
    at = _run(_anteriores() + _atuais(), _cadastros(["c1", "c2", "c3", "c4"]))

    assert at.sidebar.radio[0].value == "atual"
    assert _metric(at, "Total de Respostas") == "2"
    # KPIs dos dois eixos do orientador: (5 + 3) / 2 = 4.00
    assert _metric(at, "IHC & Acessibilidade") == "4.00"
    assert _metric(at, "Qualidade Técnica") == "4.00"
    # Contagem por versão no seletor
    opcoes = at.sidebar.radio[0].options
    assert any("Atual" in o and "(2)" in o for o in opcoes)
    assert any("Anterior" in o and "(2)" in o for o in opcoes)


def test_versao_anterior_mostra_respostas_arquivadas():
    at = _run(_anteriores() + _atuais(), _cadastros(["c1", "c2", "c3", "c4"]),
              versao="anterior")

    assert _metric(at, "Total de Respostas") == "2"
    # (4 + 2) / 2 = 3.00
    assert _metric(at, "Usabilidade") == "3.00"
    assert _metric(at, "Utilidade") == "3.00"


def test_cadastros_da_versao_atual_so_a_partir_da_troca():
    at = _run(_anteriores() + _atuais(), _cadastros_misturados())

    assert _metric(at, "Total de Cadastros") == "3"
    assert _metric(at, "Responderam o Questionário") == "2"


def test_cadastros_da_versao_anterior_so_antes_da_troca():
    at = _run(_anteriores() + _atuais(), _cadastros_misturados(), versao="anterior")

    assert _metric(at, "Total de Cadastros") == "2"
    assert _metric(at, "Responderam o Questionário") == "2"


def test_sem_cadastros_novos_a_versao_atual_comeca_zerada():
    # Situação real hoje: todos os cadastros são de antes da troca.
    at = _run(_anteriores(), _cadastros(["c1", "c2"]))

    assert "Nenhum cadastro a partir de" in _textos(at)


def test_sem_respostas_novas_orienta_a_ver_o_arquivado():
    # Situação real hoje: só existem respostas do questionário anterior.
    at = _run(_anteriores(), _cadastros(["c1", "c2"]))

    assert "Ainda não há respostas com o questionário atual" in _textos(at)
    assert any("Anterior" in o and "(2)" in o for o in at.sidebar.radio[0].options)


@pytest.mark.parametrize("versao", ["atual", "anterior"])
def test_selecao_de_secoes_so_tem_secoes_da_versao(versao):
    at = _run(_anteriores() + _atuais(), _cadastros(["c1"]), versao=versao)

    secoes = next(s for s in at.selectbox if s.label == "Seção do questionário").options
    if versao == "atual":
        assert "IHC & Acessibilidade em Libras" in secoes
        assert "Usabilidade" not in secoes
    else:
        assert "Usabilidade" in secoes
        assert "IHC & Acessibilidade em Libras" not in secoes
