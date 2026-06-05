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
    respostas: List[Resposta]
    timestamp: datetime
