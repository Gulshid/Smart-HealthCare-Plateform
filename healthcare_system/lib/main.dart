import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/risk_api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HealthRiskApp());
}

class HealthRiskApp extends StatelessWidget {
  const HealthRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = RiskApiService(baseUrl: 'http://localhost:8000');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Healthcare Risk',
      theme: buildAppTheme(),
      home: SplashScreen(apiService: apiService),
    );
  }
}
