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
