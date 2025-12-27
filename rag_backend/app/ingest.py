import uuid
import re
import io
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.db import SessionLocal, Chunk
from app.llm import embed_text
from pypdf import PdfReader

router = APIRouter()

def clean_text(text: str) -> str:
    text = text.replace("\x00", "")
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def chunk_text(text: str, chunk_size=1000, overlap=200):
    chunks = []
    start = 0

    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start = end - overlap

    return chunks

@router.post("/ingest")
async def ingest(file: UploadFile = File(...)):
    # enforce PDF only (minimal but critical)
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    raw = await file.read()

    # 🔑 PDF text extraction (THIS fixes the gibberish)
    reader = PdfReader(io.BytesIO(raw))
    text = " ".join(page.extract_text() or "" for page in reader.pages)

    text = clean_text(text)

    if not text:
        raise HTTPException(status_code=400, detail="No extractable text found in PDF")

    chunks = chunk_text(text)

    db = SessionLocal()
    document_id = str(uuid.uuid4())

    for chunk in chunks:
        db.add(
            Chunk(
                id=str(uuid.uuid4()),
                document_id=document_id,
                text=chunk,
                embedding=embed_text(chunk)
            )
        )

    db.commit()

    return {
        "status": "ok",
        "document_id": document_id,
        "chunks": len(chunks)
    }
