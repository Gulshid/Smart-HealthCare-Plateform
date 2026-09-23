import 'package:flutter/material.dart';

/// A simple card showing a condition's risk probability, band, and top factors.
class RiskGauge extends StatelessWidget {
  final String title;
  final double probability; // 0.0 - 1.0
  final String band; // Low | Moderate | High
  final List<String> topFactors;

  const RiskGauge({
    super.key,
    required this.title,
    required this.probability,
    required this.band,
    required this.topFactors,
  });

  Color get _bandColor {
    switch (band) {
      case 'Low':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bandColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    band,
                    style: TextStyle(
                        color: _bandColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: probability,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_bandColor),
              ),
            ),
            const SizedBox(height: 6),
            Text('${(probability * 100).toStringAsFixed(1)}% estimated risk',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            if (topFactors.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: topFactors
                    .map((f) => Chip(
                          label: Text(f, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
