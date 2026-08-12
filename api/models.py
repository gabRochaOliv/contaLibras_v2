from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class Resposta(BaseModel):
    pergunta_id: int
    valor: int


class CadastroPayload(BaseModel):
    nome: str
    idade: int
    categoria: str
    escolaridade: str
    usa_libras: bool
    conhecimento_libras: str


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
    cadastro_id: Optional[str] = None
