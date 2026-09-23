import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/risk_models.dart';

/// Handles all communication with the Smart Healthcare Risk Prediction API.
///
/// During local development:
///   - Android emulator -> use http://10.0.2.2:8000
///   - iOS simulator    -> use http://localhost:8000
///   - Physical device  -> use your machine's LAN IP, e.g. http://192.168.1.5:8000
///   - Production       -> your deployed backend URL (Render/Railway/EC2/etc.)
class RiskApiService {
  final String baseUrl;

  RiskApiService({required this.baseUrl});

  Future<RiskResult> predictDiabetes(DiabetesInput input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/diabetes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 200) {
      throw ApiException('Diabetes prediction failed: ${response.body}');
    }
    return RiskResult.fromJson(jsonDecode(response.body));
  }

  Future<RiskResult> predictHeart(HeartInput input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/heart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 200) {
      throw ApiException('Heart prediction failed: ${response.body}');
    }
    return RiskResult.fromJson(jsonDecode(response.body));
  }

  Future<CombinedRiskResult> predictAll(
      DiabetesInput diabetes, HeartInput heart) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'diabetes': diabetes.toJson(),
        'heart': heart.toJson(),
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('Combined prediction failed: ${response.body}');
    }
    return CombinedRiskResult.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> explainDiabetes() async {
    final response = await http.get(Uri.parse('$baseUrl/explain/diabetes'));
    if (response.statusCode != 200) {
      throw ApiException('Explain diabetes failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> explainHeart() async {
    final response = await http.get(Uri.parse('$baseUrl/explain/heart'));
    if (response.statusCode != 200) {
      throw ApiException('Explain heart failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
