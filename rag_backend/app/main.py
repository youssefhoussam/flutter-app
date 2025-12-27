from fastapi import FastAPI
from app.db import init_db
from app.ask import router as ask_router
from app.ingest import router as ingest_router

app = FastAPI(title="RAG Backend")

init_db()

app.include_router(ask_router)
app.include_router(ingest_router)

@app.get("/health")
def health():
    return {"status": "ok"}