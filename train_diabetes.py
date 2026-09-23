"""
Train diabetes risk prediction model on the Pima Indians Diabetes dataset.
Columns (no header in source file):
Pregnancies, Glucose, BloodPressure, SkinThickness, Insulin, BMI,
DiabetesPedigreeFunction, Age, Outcome
"""
import pandas as pd
import numpy as np
import joblib
import json
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
)

COLS = [
    "Pregnancies", "Glucose", "BloodPressure", "SkinThickness", "Insulin",
    "BMI", "DiabetesPedigreeFunction", "Age", "Outcome"
]

df = pd.read_csv("data/diabetes.csv", names=COLS)

# Pima dataset uses 0 as a missing-value placeholder for several columns.
# Replace those zeros with NaN, then impute with the column median.
zero_as_missing = ["Glucose", "BloodPressure", "SkinThickness", "Insulin", "BMI"]
for col in zero_as_missing:
    df[col] = df[col].replace(0, np.nan)
    df[col] = df[col].fillna(df[col].median())

X = df.drop(columns=["Outcome"])
y = df["Outcome"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

models = {
    "logistic_regression": LogisticRegression(max_iter=1000),
    "random_forest": RandomForestClassifier(n_estimators=300, max_depth=6, random_state=42),
    "xgboost": XGBClassifier(n_estimators=300, max_depth=4, learning_rate=0.05,
                              eval_metric="logloss", random_state=42),
}

results = {}
best_name, best_model, best_f1 = None, None, -1

for name, model in models.items():
    model.fit(X_train_scaled, y_train)
    preds = model.predict(X_test_scaled)
    probs = model.predict_proba(X_test_scaled)[:, 1]

    metrics = {
        "accuracy": round(accuracy_score(y_test, preds), 4),
        "precision": round(precision_score(y_test, preds), 4),
        "recall": round(recall_score(y_test, preds), 4),
        "f1": round(f1_score(y_test, preds), 4),
        "roc_auc": round(roc_auc_score(y_test, probs), 4),
    }
    results[name] = metrics
    print(f"{name}: {metrics}")

    if metrics["f1"] > best_f1:
        best_f1 = metrics["f1"]
        best_name = name
        best_model = model

print(f"\nBest model: {best_name} (F1={best_f1})")

# Feature importance (for explainability) — use RF/XGB importances if available,
# fall back to |coefficients| for logistic regression.
if hasattr(best_model, "feature_importances_"):
    importances = best_model.feature_importances_
else:
    importances = np.abs(best_model.coef_[0])

feature_importance = dict(zip(X.columns, [round(float(i), 4) for i in importances]))
feature_importance = dict(sorted(feature_importance.items(), key=lambda x: -x[1]))

# Save artifacts
joblib.dump(best_model, "models/diabetes_model.pkl")
joblib.dump(scaler, "models/diabetes_scaler.pkl")

with open("models/diabetes_meta.json", "w") as f:
    json.dump({
        "best_model": best_name,
        "metrics": results[best_name],
        "all_results": results,
        "feature_order": list(X.columns),
        "feature_importance": feature_importance,
    }, f, indent=2)

print("\nSaved: models/diabetes_model.pkl, models/diabetes_scaler.pkl, models/diabetes_meta.json")
