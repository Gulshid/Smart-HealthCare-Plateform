"""
Smart Healthcare Risk Prediction API
--------------------------------------
Serves diabetes and heart disease risk predictions from pre-trained models.
Run with: uvicorn main:app --reload --host 0.0.0.0 --port 8000

IMPORTANT: This is a research/decision-support demo trained on small public
datasets (Pima Diabetes, UCI Cleveland Heart Disease). It is NOT a medical
device and must never be presented as a diagnosis.
"""
import json
import joblib
import numpy as np
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

BASE_DIR = Path(__file__).resolve().parent.parent
MODELS_DIR = BASE_DIR / "models"

app = FastAPI(
    title="Smart Healthcare Risk Prediction API",
    description="Research/decision-support risk scoring. Not a medical diagnosis.",
    version="1.0.0",
)

# Allow the Flutter app (web/mobile/emulator) to call this API during development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- Load models + metadata at startup ----------
diabetes_model = joblib.load(MODELS_DIR / "diabetes_model.pkl")
diabetes_scaler = joblib.load(MODELS_DIR / "diabetes_scaler.pkl")
diabetes_meta = json.loads((MODELS_DIR / "diabetes_meta.json").read_text())

heart_model = joblib.load(MODELS_DIR / "heart_model.pkl")
heart_scaler = joblib.load(MODELS_DIR / "heart_scaler.pkl")
heart_meta = json.loads((MODELS_DIR / "heart_meta.json").read_text())


def risk_band(prob: float) -> str:
    if prob < 0.33:
        return "Low"
    elif prob < 0.66:
        return "Moderate"
    return "High"


# ---------- Request schemas ----------
class DiabetesInput(BaseModel):
    pregnancies: int = Field(..., ge=0, le=20)
    glucose: float = Field(..., ge=0, le=300)
    blood_pressure: float = Field(..., ge=0, le=200)
    skin_thickness: float = Field(..., ge=0, le=100)
    insulin: float = Field(..., ge=0, le=900)
    bmi: float = Field(..., ge=0, le=80)
    diabetes_pedigree_function: float = Field(..., ge=0, le=3)
    age: int = Field(..., ge=1, le=120)


class HeartInput(BaseModel):
    age: int = Field(..., ge=1, le=120)
    sex: int = Field(..., ge=0, le=1, description="1 = male, 0 = female")
    cp: int = Field(..., ge=0, le=3, description="chest pain type (0-3)")
    trestbps: float = Field(..., description="resting blood pressure")
    chol: float = Field(..., description="serum cholesterol mg/dl")
    fbs: int = Field(..., ge=0, le=1, description="fasting blood sugar > 120 mg/dl")
    restecg: int = Field(..., ge=0, le=2)
    thalach: float = Field(..., description="max heart rate achieved")
    exang: int = Field(..., ge=0, le=1, description="exercise induced angina")
    oldpeak: float = Field(..., description="ST depression induced by exercise")
    slope: int = Field(..., ge=0, le=2)
    ca: int = Field(..., ge=0, le=4, description="number of major vessels")
    thal: int = Field(..., ge=0, le=3)


class CombinedInput(BaseModel):
    diabetes: DiabetesInput
    heart: HeartInput


# ---------- Helpers ----------
def predict_diabetes(payload: DiabetesInput):
    order = diabetes_meta["feature_order"]
    field_map = {
        "Pregnancies": payload.pregnancies,
        "Glucose": payload.glucose,
        "BloodPressure": payload.blood_pressure,
        "SkinThickness": payload.skin_thickness,
        "Insulin": payload.insulin,
        "BMI": payload.bmi,
        "DiabetesPedigreeFunction": payload.diabetes_pedigree_function,
        "Age": payload.age,
    }
    x = np.array([[field_map[f] for f in order]])
    x_scaled = diabetes_scaler.transform(x)
    prob = float(diabetes_model.predict_proba(x_scaled)[0, 1])
    return {
        "condition": "diabetes",
        "risk_probability": round(prob, 4),
        "risk_band": risk_band(prob),
        "model_used": diabetes_meta["best_model"],
        "top_factors": list(diabetes_meta["feature_importance"].keys())[:3],
    }


def predict_heart(payload: HeartInput):
    order = heart_meta["feature_order"]
    field_map = {
        "age": payload.age, "sex": payload.sex, "cp": payload.cp,
        "trestbps": payload.trestbps, "chol": payload.chol, "fbs": payload.fbs,
        "restecg": payload.restecg, "thalach": payload.thalach,
        "exang": payload.exang, "oldpeak": payload.oldpeak,
        "slope": payload.slope, "ca": payload.ca, "thal": payload.thal,
    }
    x = np.array([[field_map[f] for f in order]])
    x_scaled = heart_scaler.transform(x)
    prob = float(heart_model.predict_proba(x_scaled)[0, 1])
    return {
        "condition": "heart_disease",
        "risk_probability": round(prob, 4),
        "risk_band": risk_band(prob),
        "model_used": heart_meta["best_model"],
        "top_factors": list(heart_meta["feature_importance"].keys())[:3],
    }


# ---------- Routes ----------
@app.get("/")
def root():
    return {
        "status": "ok",
        "message": "Smart Healthcare Risk Prediction API",
        "disclaimer": "Research/decision-support only. Not a medical diagnosis.",
        "endpoints": ["/predict/diabetes", "/predict/heart", "/predict/all",
                       "/explain/diabetes", "/explain/heart"],
    }


@app.post("/predict/diabetes")
def diabetes_endpoint(payload: DiabetesInput):
    try:
        return predict_diabetes(payload)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/predict/heart")
def heart_endpoint(payload: HeartInput):
    try:
        return predict_heart(payload)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/predict/all")
def combined_endpoint(payload: CombinedInput):
    try:
        diabetes_result = predict_diabetes(payload.diabetes)
        heart_result = predict_heart(payload.heart)
        overall = max(diabetes_result["risk_probability"], heart_result["risk_probability"])
        return {
            "diabetes": diabetes_result,
            "heart_disease": heart_result,
            "overall_risk_band": risk_band(overall),
            "disclaimer": "This is a research/decision-support estimate, not a medical diagnosis. Consult a healthcare professional.",
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/explain/diabetes")
def explain_diabetes():
    return {
        "model": diabetes_meta["best_model"],
        "metrics": diabetes_meta["metrics"],
        "feature_importance": diabetes_meta["feature_importance"],
    }


@app.get("/explain/heart")
def explain_heart():
    return {
        "model": heart_meta["best_model"],
        "metrics": heart_meta["metrics"],
        "feature_importance": heart_meta["feature_importance"],
    }
