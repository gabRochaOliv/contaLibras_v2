import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import FeedbackPayload
from database import insert_feedback

app = FastAPI(title="ContaLibras Feedback API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://conta-libras.vercel.app"],
    allow_origin_regex=r"http://localhost(:\d+)?",
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


@app.get("/health")
@app.get("/api/main/health")
def health():
    return {"status": "ok"}


@app.post("/feedback", status_code=201)
@app.post("/api/main/feedback", status_code=201)
def post_feedback(payload: FeedbackPayload):
    try:
        insert_feedback(payload)
        return {"message": "Feedback recebido com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
