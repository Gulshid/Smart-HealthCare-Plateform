import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../widgets/risk_gauge.dart';

class RiskResultScreen extends StatelessWidget {
  final CombinedRiskResult result;
  const RiskResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Risk Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Overall risk band: ${result.overallRiskBand}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RiskGauge(
            title: 'Diabetes',
            probability: result.diabetes.riskProbability,
            band: result.diabetes.riskBand,
            topFactors: result.diabetes.topFactors,
          ),
          const SizedBox(height: 12),
          RiskGauge(
            title: 'Heart Disease',
            probability: result.heart.riskProbability,
            band: result.heart.riskBand,
            topFactors: result.heart.topFactors,
          ),
          const SizedBox(height: 20),
          Text(result.disclaimer,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}
