import requests
from app.config import LMSTUDIO_EMBED_BASE_URL,LMSTUDIO_EMBED_MODEL, LMSTUDIO_LLM_BASE_URL, LMSTUDIO_LLM_MODEL

def embed_text(text: str) -> list[float]:
    r = requests.post(
        f"{LMSTUDIO_EMBED_BASE_URL}/embeddings",
        json={
            "model": LMSTUDIO_EMBED_MODEL,
            "input": text
        },
        timeout=30
    )
    r.raise_for_status()
    return r.json()["data"][0]["embedding"]

def ask_llm(context: str, question: str) -> str:
    prompt = f"""
Use the following context to answer the question.

Context:
{context}

Question:
{question}

Answer:
"""
    r = requests.post(
        f"{LMSTUDIO_LLM_BASE_URL}/chat/completions",
        headers={
            "Content-Type": "application/json"
        },
        json={
            "model": LMSTUDIO_LLM_MODEL,
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.2
        },
        timeout=60
    )
    r.raise_for_status()
    return r.json()["choices"][0]["message"]["content"]