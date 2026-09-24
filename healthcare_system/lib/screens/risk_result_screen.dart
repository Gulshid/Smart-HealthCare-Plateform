import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_arc_gauge.dart';

class RiskResultScreen extends StatelessWidget {
  final CombinedRiskResult result;
  const RiskResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final overallColor = AppColors.riskColor(result.overallRiskBand);

    return Scaffold(
      appBar: AppBar(title: const Text('Risk report')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          children: [
            // Report header — states the top-line finding immediately,
            // like the summary line of a lab report.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall assessment',
                      style: AppType.body(size: 12, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(result.overallRiskBand,
                          style: AppType.display(
                              size: 30, color: Colors.white, weight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: overallColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ConditionReport(
              title: 'Diabetes',
              result: result.diabetes,
            ),
            const SizedBox(height: 16),
            _ConditionReport(
              title: 'Heart disease',
              result: result.heart,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.disclaimer,
                    style: AppType.body(size: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionReport extends StatelessWidget {
  final String title;
  final RiskResult result;

  const _ConditionReport({required this.title, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(result.riskBand);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RiskArcGauge(probability: result.riskProbability, band: result.riskBand, size: 96),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: AppType.display(size: 17)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.riskBg(result.riskBand),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.riskBand,
                        style: AppType.body(size: 11, weight: FontWeight.w700, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Model: ${_formatModel(result.modelUsed)}',
                    style: AppType.body(size: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Text('Top contributing factors',
                    style: AppType.body(size: 11, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: result.topFactors
                      .map((f) => Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            child: Text(f,
                                style:
                                    AppType.data(size: 11, color: AppColors.textPrimary)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatModel(String raw) {
    return raw
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
