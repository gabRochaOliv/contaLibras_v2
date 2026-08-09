from pydantic import BaseModel
from typing import List
from datetime import datetime


class Resposta(BaseModel):
    pergunta_id: int
    valor: int


class FeedbackPayload(BaseModel):
    nome: str
    idade: int
    categoria: str
    escolaridade: str
    usa_libras: bool
    conhecimento_libras: str
    comentario_gostou: str = ""
    comentario_melhorar: str = ""
    comentario_sugestao: str = ""
    respostas: List[Resposta]
    timestamp: datetime
