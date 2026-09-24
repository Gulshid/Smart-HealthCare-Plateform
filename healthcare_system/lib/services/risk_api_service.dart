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

  /// Turns a FastAPI/Pydantic 422 validation error body into a
  /// human-readable message, e.g. "diabetes.pregnancies: Input should
  /// be less than or equal to 20 (got 23)." Falls back to the raw
  /// body for anything else (network errors, 500s, etc.).
  String _describeError(int statusCode, String body) {
    if (statusCode == 422) {
      try {
        final decoded = jsonDecode(body);
        final details = decoded['detail'] as List?;
        if (details != null && details.isNotEmpty) {
          final messages = details.map((d) {
            final loc = (d['loc'] as List?)?.skip(1).join('.') ?? 'field';
            final msg = d['msg'] ?? 'invalid value';
            final input = d['input'];
            return '$loc: $msg${input != null ? ' (got $input)' : ''}';
          }).join('\n');
          return messages;
        }
      } catch (_) {
        // Fall through to the generic message below.
      }
    }
    return 'Server returned an error (status $statusCode): $body';
  }

  Future<RiskResult> predictDiabetes(DiabetesInput input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/diabetes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 200) {
      throw ApiException(_describeError(response.statusCode, response.body));
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
      throw ApiException(_describeError(response.statusCode, response.body));
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
      throw ApiException(_describeError(response.statusCode, response.body));
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
