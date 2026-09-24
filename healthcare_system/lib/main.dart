import 'package:flutter/material.dart';
import 'screens/risk_input_screen.dart';
import 'services/risk_api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HealthRiskApp());
}

class HealthRiskApp extends StatelessWidget {
  const HealthRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change baseUrl depending on where you run the backend:
    //   Android emulator -> http://10.0.2.2:8000
    //   iOS simulator    -> http://localhost:8000
    //   Physical device  -> http://<your-lan-ip>:8000
    //   Production       -> your deployed API URL
    final apiService = RiskApiService(baseUrl: 'http://localhost:8000');

    return MaterialApp(
      title: 'Smart Healthcare Risk',
      theme: buildAppTheme(),
      home: RiskInputScreen(apiService: apiService),
    );
  }
}
