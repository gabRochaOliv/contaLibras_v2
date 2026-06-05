"""Testes unitários de autenticação — usa apenas hmac (stdlib), sem Streamlit."""
import hmac
import time


def test_hmac_senha_correta():
    assert hmac.compare_digest("senha123", "senha123") is True


def test_hmac_senha_errada():
    assert hmac.compare_digest("errada", "senha123") is False


def test_hmac_senha_vazia():
    assert hmac.compare_digest("", "senha123") is False


def test_hmac_timing_safe():
    resultados = []
    for _ in range(3):
        r1 = hmac.compare_digest("x" * 100, "y" * 100)
        r2 = hmac.compare_digest("x" * 100, "x" * 100)
        assert isinstance(r1, bool)
        assert isinstance(r2, bool)
        resultados.append((r1, r2))
    assert all(r1 is False and r2 is True for r1, r2 in resultados)
