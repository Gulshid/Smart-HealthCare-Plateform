"""
Train heart disease risk prediction model on the UCI Cleveland Heart Disease dataset.
Columns: age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
         slope, ca, thal, target
"""
import pandas as pd
import numpy as np
import joblib
import json
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
)

df = pd.read_csv("data/heart.csv", encoding="utf-8-sig")
df.columns = [c.strip() for c in df.columns]

X = df.drop(columns=["target"])
y = df["target"]

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

if hasattr(best_model, "feature_importances_"):
    importances = best_model.feature_importances_
else:
    importances = np.abs(best_model.coef_[0])

feature_importance = dict(zip(X.columns, [round(float(i), 4) for i in importances]))
feature_importance = dict(sorted(feature_importance.items(), key=lambda x: -x[1]))

joblib.dump(best_model, "models/heart_model.pkl")
joblib.dump(scaler, "models/heart_scaler.pkl")

with open("models/heart_meta.json", "w") as f:
    json.dump({
        "best_model": best_name,
        "metrics": results[best_name],
        "all_results": results,
        "feature_order": list(X.columns),
        "feature_importance": feature_importance,
    }, f, indent=2)

print("\nSaved: models/heart_model.pkl, models/heart_scaler.pkl, models/heart_meta.json")
