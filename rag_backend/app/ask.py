from fastapi import APIRouter
from sqlalchemy import text
from app.db import SessionLocal
from app.llm import embed_text, ask_llm
from app.schemas import AskRequest, AskResponse

router = APIRouter()

@router.post("/ask", response_model=AskResponse)
def ask(req: AskRequest):
    embedding = embed_text(req.question)

    db = SessionLocal()
    rows = db.execute(
        text("""
            SELECT text
            FROM chunks
            ORDER BY embedding <-> (:embedding)::vector
            LIMIT :k
        """),
        {"embedding": embedding, "k": req.top_k}
    ).fetchall()

    context = "\n\n".join(r[0] for r in rows)
    answer = ask_llm(context, req.question)

    return AskResponse(answer=answer)
