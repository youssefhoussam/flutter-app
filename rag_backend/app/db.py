from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from pgvector.sqlalchemy import Vector
from sqlalchemy import Column, Text
from sqlalchemy.ext.declarative import declarative_base
from app.config import POSTGRES_URL

engine = create_engine(POSTGRES_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()


class Chunk(Base):
    __tablename__ = "chunks"

    id = Column(Text, primary_key=True)
    document_id = Column(Text, index=True)
    text = Column(Text)
    embedding = Column(Vector(1024))  # match your embedding model dim


def init_db():
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
    Base.metadata.create_all(bind=engine)
