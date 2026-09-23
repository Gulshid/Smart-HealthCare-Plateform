/// Data models mirroring the FastAPI response schemas.

class RiskResult {
  final String condition;
  final double riskProbability;
  final String riskBand; // Low | Moderate | High
  final String modelUsed;
  final List<String> topFactors;

  RiskResult({
    required this.condition,
    required this.riskProbability,
    required this.riskBand,
    required this.modelUsed,
    required this.topFactors,
  });

  factory RiskResult.fromJson(Map<String, dynamic> json) {
    return RiskResult(
      condition: json['condition'] as String,
      riskProbability: (json['risk_probability'] as num).toDouble(),
      riskBand: json['risk_band'] as String,
      modelUsed: json['model_used'] as String,
      topFactors: List<String>.from(json['top_factors'] as List),
    );
  }
}

class CombinedRiskResult {
  final RiskResult diabetes;
  final RiskResult heart;
  final String overallRiskBand;
  final String disclaimer;

  CombinedRiskResult({
    required this.diabetes,
    required this.heart,
    required this.overallRiskBand,
    required this.disclaimer,
  });

  factory CombinedRiskResult.fromJson(Map<String, dynamic> json) {
    return CombinedRiskResult(
      diabetes: RiskResult.fromJson(json['diabetes']),
      heart: RiskResult.fromJson(json['heart_disease']),
      overallRiskBand: json['overall_risk_band'] as String,
      disclaimer: json['disclaimer'] as String,
    );
  }
}

/// Input fields collected from the user for the diabetes model.
class DiabetesInput {
  final int pregnancies;
  final double glucose;
  final double bloodPressure;
  final double skinThickness;
  final double insulin;
  final double bmi;
  final double diabetesPedigreeFunction;
  final int age;

  DiabetesInput({
    required this.pregnancies,
    required this.glucose,
    required this.bloodPressure,
    required this.skinThickness,
    required this.insulin,
    required this.bmi,
    required this.diabetesPedigreeFunction,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
        'pregnancies': pregnancies,
        'glucose': glucose,
        'blood_pressure': bloodPressure,
        'skin_thickness': skinThickness,
        'insulin': insulin,
        'bmi': bmi,
        'diabetes_pedigree_function': diabetesPedigreeFunction,
        'age': age,
      };
}

/// Input fields collected from the user for the heart disease model.
class HeartInput {
  final int age;
  final int sex; // 1 = male, 0 = female
  final int cp; // chest pain type 0-3
  final double trestbps; // resting blood pressure
  final double chol; // cholesterol
  final int fbs; // fasting blood sugar > 120 mg/dl
  final int restecg;
  final double thalach; // max heart rate
  final int exang; // exercise induced angina
  final double oldpeak;
  final int slope;
  final int ca;
  final int thal;

  HeartInput({
    required this.age,
    required this.sex,
    required this.cp,
    required this.trestbps,
    required this.chol,
    required this.fbs,
    required this.restecg,
    required this.thalach,
    required this.exang,
    required this.oldpeak,
    required this.slope,
    required this.ca,
    required this.thal,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'sex': sex,
        'cp': cp,
        'trestbps': trestbps,
        'chol': chol,
        'fbs': fbs,
        'restecg': restecg,
        'thalach': thalach,
        'exang': exang,
        'oldpeak': oldpeak,
        'slope': slope,
        'ca': ca,
        'thal': thal,
      };
}
