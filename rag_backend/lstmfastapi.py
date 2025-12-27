from fastapi import FastAPI
from pydantic import BaseModel
import tensorflow as tf
import numpy as np
import joblib

# Load trained artifacts
model = tf.keras.models.load_model("lstm.keras")
scaler = joblib.load("scaler.save")

app = FastAPI()

class PredictRequest(BaseModel):
    sequence: list[float]  # real prices (not scaled)

@app.post("/predict")
def predict(req: PredictRequest):
    if len(req.sequence) != 60:
        return {"error": "Sequence must contain exactly 60 values"}

    # 1️⃣ Convert input to numpy array
    sequence_np = np.array(req.sequence, dtype=np.float32).reshape(-1, 1)

    # 2️⃣ SCALE input using the SAME scaler as training
    sequence_scaled = scaler.transform(sequence_np)

    # 3️⃣ Reshape for LSTM: (1, 60, 1)
    x = sequence_scaled.reshape(1, 60, 1)

    # 4️⃣ Predict (still scaled)
    y_scaled = model.predict(x)

    # 5️⃣ INVERSE SCALE prediction back to real price
    y_real = scaler.inverse_transform(y_scaled)

    return {
        "prediction": float(y_real[0][0])
    }
