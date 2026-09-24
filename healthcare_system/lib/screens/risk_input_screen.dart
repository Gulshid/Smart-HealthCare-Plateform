import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../services/risk_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/step_tracker.dart';
import 'risk_result_screen.dart';

class RiskInputScreen extends StatefulWidget {
  final RiskApiService apiService;
  const RiskInputScreen({super.key, required this.apiService});

  @override
  State<RiskInputScreen> createState() => _RiskInputScreenState();
}

class _RiskInputScreenState extends State<RiskInputScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _loading = false;
  static const _stepLabels = ['Basics', 'Diabetes', 'Heart'];

  // Shared
  final _ageCtrl = TextEditingController(text: '45');
  int _sex = 1;

  // Diabetes fields
  final _pregnanciesCtrl = TextEditingController(text: '1');
  final _glucoseCtrl = TextEditingController(text: '120');
  final _bpCtrl = TextEditingController(text: '75');
  final _skinCtrl = TextEditingController(text: '25');
  final _insulinCtrl = TextEditingController(text: '90');
  final _bmiCtrl = TextEditingController(text: '27.5');
  final _pedigreeCtrl = TextEditingController(text: '0.4');

  // Heart fields
  int _cp = 0;
  final _trestbpsCtrl = TextEditingController(text: '120');
  final _cholCtrl = TextEditingController(text: '200');
  int _fbs = 0;
  int _restecg = 0;
  final _thalachCtrl = TextEditingController(text: '150');
  int _exang = 0;
  final _oldpeakCtrl = TextEditingController(text: '0.5');
  int _slope = 1;
  int _ca = 0;
  int _thal = 2;

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _ageCtrl, _pregnanciesCtrl, _glucoseCtrl, _bpCtrl, _skinCtrl,
      _insulinCtrl, _bmiCtrl, _pedigreeCtrl, _trestbpsCtrl, _cholCtrl,
      _thalachCtrl, _oldpeakCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  /// Runs the form's validators (checked ranges match the backend's
  /// exactly) before advancing, so bad values are caught here instead
  /// of round-tripping to the API and coming back as a 422.
  bool _validateAndReport() {
    final valid = _formKey.currentState?.validate() ?? true;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted field before continuing.')),
      );
    }
    return valid;
  }

  Future<void> _submit() async {
    if (!_validateAndReport()) return;
    setState(() => _loading = true);
    try {
      final age = int.tryParse(_ageCtrl.text) ?? 45;

      final diabetesInput = DiabetesInput(
        pregnancies: int.tryParse(_pregnanciesCtrl.text) ?? 0,
        glucose: double.tryParse(_glucoseCtrl.text) ?? 0,
        bloodPressure: double.tryParse(_bpCtrl.text) ?? 0,
        skinThickness: double.tryParse(_skinCtrl.text) ?? 0,
        insulin: double.tryParse(_insulinCtrl.text) ?? 0,
        bmi: double.tryParse(_bmiCtrl.text) ?? 0,
        diabetesPedigreeFunction: double.tryParse(_pedigreeCtrl.text) ?? 0,
        age: age,
      );

      final heartInput = HeartInput(
        age: age,
        sex: _sex,
        cp: _cp,
        trestbps: double.tryParse(_trestbpsCtrl.text) ?? 0,
        chol: double.tryParse(_cholCtrl.text) ?? 0,
        fbs: _fbs,
        restecg: _restecg,
        thalach: double.tryParse(_thalachCtrl.text) ?? 0,
        exang: _exang,
        oldpeak: double.tryParse(_oldpeakCtrl.text) ?? 0,
        slope: _slope,
        ca: _ca,
        thal: _thal,
      );

      final result = await widget.apiService.predictAll(diabetesInput, heartInput);
      if (!mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => RiskResultScreen(result: result)));
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.message // already a friendly, parsed message
          : 'Couldn\'t reach the server. Is it running? ($e)';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Risk Assessment')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: StepTracker(labels: _stepLabels, currentIndex: _step),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _StepScaffold(
                    title: 'Basic information',
                    subtitle:
                        'Used by both models. This tool gives a research/decision-support estimate — not a medical diagnosis.',
                    children: [
                      _LabeledField(label: 'Age', controller: _ageCtrl, min: 1, max: 120),
                      const SizedBox(height: 16),
                      _SegmentedToggle(
                        label: 'Sex',
                        value: _sex,
                        options: const {1: 'Male', 0: 'Female'},
                        onChanged: (v) => setState(() => _sex = v),
                      ),
                    ],
                  ),
                  _StepScaffold(
                    title: 'Diabetes indicators',
                    subtitle: 'From routine blood work and vitals.',
                    children: [
                      _LabeledField(
                          label: 'Pregnancies', controller: _pregnanciesCtrl, min: 0, max: 20),
                      _LabeledField(
                          label: 'Glucose (mg/dL)', controller: _glucoseCtrl, min: 0, max: 300),
                      _LabeledField(
                          label: 'Blood pressure (mm Hg)', controller: _bpCtrl, min: 0, max: 200),
                      _LabeledField(
                          label: 'Skin thickness (mm)', controller: _skinCtrl, min: 0, max: 100),
                      _LabeledField(
                          label: 'Insulin (mu U/ml)', controller: _insulinCtrl, min: 0, max: 900),
                      _LabeledField(label: 'BMI', controller: _bmiCtrl, min: 0, max: 80),
                      _LabeledField(
                          label: 'Diabetes pedigree function',
                          controller: _pedigreeCtrl,
                          min: 0,
                          max: 3),
                    ],
                  ),
                  _StepScaffold(
                    title: 'Heart indicators',
                    subtitle: 'From an ECG or stress test, if available.',
                    children: [
                      _EnumDropdown(
                        label: 'Chest pain type',
                        value: _cp,
                        options: const {
                          0: 'Typical angina',
                          1: 'Atypical angina',
                          2: 'Non-anginal pain',
                          3: 'Asymptomatic',
                        },
                        onChanged: (v) => setState(() => _cp = v),
                      ),
                      _LabeledField(
                          label: 'Resting blood pressure', controller: _trestbpsCtrl),
                      _LabeledField(label: 'Cholesterol (mg/dl)', controller: _cholCtrl),
                      _SegmentedToggle(
                        label: 'Fasting blood sugar > 120 mg/dl',
                        value: _fbs,
                        options: const {0: 'No', 1: 'Yes'},
                        onChanged: (v) => setState(() => _fbs = v),
                      ),
                      const SizedBox(height: 16),
                      _EnumDropdown(
                        label: 'Resting ECG',
                        value: _restecg,
                        options: const {
                          0: 'Normal',
                          1: 'ST-T wave abnormality',
                          2: 'Left ventricular hypertrophy',
                        },
                        onChanged: (v) => setState(() => _restecg = v),
                      ),
                      _LabeledField(
                          label: 'Max heart rate achieved', controller: _thalachCtrl),
                      _SegmentedToggle(
                        label: 'Exercise-induced angina',
                        value: _exang,
                        options: const {0: 'No', 1: 'Yes'},
                        onChanged: (v) => setState(() => _exang = v),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                          label: 'ST depression (oldpeak)', controller: _oldpeakCtrl),
                      _EnumDropdown(
                        label: 'ST segment slope',
                        value: _slope,
                        options: const {0: 'Upsloping', 1: 'Flat', 2: 'Downsloping'},
                        onChanged: (v) => setState(() => _slope = v),
                      ),
                      _EnumDropdown(
                        label: 'Major vessels colored',
                        value: _ca,
                        options: const {0: '0', 1: '1', 2: '2', 3: '3', 4: '4'},
                        onChanged: (v) => setState(() => _ca = v),
                      ),
                      _EnumDropdown(
                        label: 'Thalassemia',
                        value: _thal,
                        options: const {
                          0: 'Normal',
                          1: 'Fixed defect',
                          2: 'Reversible defect',
                          3: 'Not specified',
                        },
                        onChanged: (v) => setState(() => _thal = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => _goTo(_step - 1),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _loading
                          ? null
                          : () {
                              if (_step < 2) {
                                if (_validateAndReport()) _goTo(_step + 1);
                              } else {
                                _submit();
                              }
                            },
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_step < 2 ? 'Continue' : 'Get risk assessment'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StepScaffold(
      {required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppType.display(size: 24)),
          const SizedBox(height: 6),
          Text(subtitle, style: AppType.body(size: 13, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ...children.expand((w) => [w, const SizedBox(height: 16)]),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final num? min;
  final num? max;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.min,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final rangeHint = (min != null && max != null) ? 'Range: $min–$max' : null;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, helperText: rangeHint),
      style: AppType.data(size: 15),
      validator: (value) {
        final v = double.tryParse(value ?? '');
        if (v == null) return 'Enter a number';
        if (min != null && v < min!) return 'Must be at least $min';
        if (max != null && v > max!) return 'Must be at most $max';
        return null;
      },
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final String label;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppType.body(size: 13, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Row(
          children: options.entries.map((e) {
            final selected = e.key == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: e.key == options.keys.last ? 0 : 8),
                child: GestureDetector(
                  onTap: () => onChanged(e.key),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ink : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.ink : AppColors.hairline,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: AppType.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EnumDropdown extends StatelessWidget {
  final String label;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(labelText: label),
      icon: const Icon(Icons.expand_more, size: 20),
      style: AppType.body(size: 15, color: AppColors.textPrimary),
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
