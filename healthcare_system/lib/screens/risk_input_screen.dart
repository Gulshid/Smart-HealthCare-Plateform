import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../services/risk_api_service.dart';
import 'risk_result_screen.dart';

/// Form to collect the inputs both models need, then calls /predict/all.
class RiskInputScreen extends StatefulWidget {
  final RiskApiService apiService;
  const RiskInputScreen({super.key, required this.apiService});

  @override
  State<RiskInputScreen> createState() => _RiskInputScreenState();
}

class _RiskInputScreenState extends State<RiskInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Shared
  final _ageCtrl = TextEditingController(text: '45');

  // Diabetes fields
  final _pregnanciesCtrl = TextEditingController(text: '1');
  final _glucoseCtrl = TextEditingController(text: '120');
  final _bpCtrl = TextEditingController(text: '75');
  final _skinCtrl = TextEditingController(text: '25');
  final _insulinCtrl = TextEditingController(text: '90');
  final _bmiCtrl = TextEditingController(text: '27.5');
  final _pedigreeCtrl = TextEditingController(text: '0.4');

  // Heart fields
  int _sex = 1;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final age = int.parse(_ageCtrl.text);

      final diabetesInput = DiabetesInput(
        pregnancies: int.parse(_pregnanciesCtrl.text),
        glucose: double.parse(_glucoseCtrl.text),
        bloodPressure: double.parse(_bpCtrl.text),
        skinThickness: double.parse(_skinCtrl.text),
        insulin: double.parse(_insulinCtrl.text),
        bmi: double.parse(_bmiCtrl.text),
        diabetesPedigreeFunction: double.parse(_pedigreeCtrl.text),
        age: age,
      );

      final heartInput = HeartInput(
        age: age,
        sex: _sex,
        cp: _cp,
        trestbps: double.parse(_trestbpsCtrl.text),
        chol: double.parse(_cholCtrl.text),
        fbs: _fbs,
        restecg: _restecg,
        thalach: double.parse(_thalachCtrl.text),
        exang: _exang,
        oldpeak: double.parse(_oldpeakCtrl.text),
        slope: _slope,
        ca: _ca,
        thal: _thal,
      );

      final result =
          await widget.apiService.predictAll(diabetesInput, heartInput);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RiskResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _numberField(String label, TextEditingController ctrl,
      {bool isDouble = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType:
            TextInputType.numberWithOptions(decimal: isDouble),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _dropdown(String label, int value, List<int> options,
      ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text('$o')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Risk Assessment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('This tool provides a research/decision-support '
                'estimate. It is not a medical diagnosis.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Text('Basic info',
                style: Theme.of(context).textTheme.titleMedium),
            _numberField('Age', _ageCtrl, isDouble: false),
            _dropdown('Sex (1=male, 0=female)', _sex, [0, 1],
                (v) => setState(() => _sex = v!)),
            const Divider(height: 32),
            Text('Diabetes indicators',
                style: Theme.of(context).textTheme.titleMedium),
            _numberField('Pregnancies', _pregnanciesCtrl, isDouble: false),
            _numberField('Glucose (mg/dL)', _glucoseCtrl),
            _numberField('Blood pressure (mm Hg)', _bpCtrl),
            _numberField('Skin thickness (mm)', _skinCtrl),
            _numberField('Insulin (mu U/ml)', _insulinCtrl),
            _numberField('BMI', _bmiCtrl),
            _numberField('Diabetes pedigree function', _pedigreeCtrl),
            const Divider(height: 32),
            Text('Heart indicators',
                style: Theme.of(context).textTheme.titleMedium),
            _dropdown('Chest pain type', _cp, [0, 1, 2, 3],
                (v) => setState(() => _cp = v!)),
            _numberField('Resting blood pressure', _trestbpsCtrl),
            _numberField('Cholesterol (mg/dl)', _cholCtrl),
            _dropdown('Fasting blood sugar > 120', _fbs, [0, 1],
                (v) => setState(() => _fbs = v!)),
            _dropdown('Resting ECG', _restecg, [0, 1, 2],
                (v) => setState(() => _restecg = v!)),
            _numberField('Max heart rate achieved', _thalachCtrl),
            _dropdown('Exercise induced angina', _exang, [0, 1],
                (v) => setState(() => _exang = v!)),
            _numberField('ST depression (oldpeak)', _oldpeakCtrl),
            _dropdown('Slope', _slope, [0, 1, 2],
                (v) => setState(() => _slope = v!)),
            _dropdown('Major vessels (ca)', _ca, [0, 1, 2, 3, 4],
                (v) => setState(() => _ca = v!)),
            _dropdown('Thal', _thal, [0, 1, 2, 3],
                (v) => setState(() => _thal = v!)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Get Risk Assessment'),
            ),
          ],
        ),
      ),
    );
  }
}
