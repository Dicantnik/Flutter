import 'package:flutter/material.dart';

class EnergyLossCalculator extends StatefulWidget {
  const EnergyLossCalculator({super.key});

  @override
  EnergyLossCalculatorState createState() => EnergyLossCalculatorState();
}

class EnergyLossCalculatorState extends State<EnergyLossCalculator> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in inputLabels.keys) key: TextEditingController()
  };

  String calculationResult = '';
  String errorText = '';

  void performCalculation() {
    final inputValues = inputControllers.map(
          (key, controller) => MapEntry(key, double.tryParse(controller.text)),
    );

    if (inputValues.values.any((value) => value == null)) {
      setState(() {
        errorText = 'Будь ласка, введіть коректні значення у всі поля.';
        calculationResult = '';
      });
      return;
    }

    final parsedValues = inputValues.map((key, value) => MapEntry(key, value!));
    final result = computeEnergyLoss(parsedValues);

    setState(() {
      calculationResult = result;
      errorText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор Втрат Енергії'),
        backgroundColor: Color(0xFF583E23),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...inputControllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: entry.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: inputLabels[entry.key],
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF583E23)),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: performCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF583E23),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Обчислити'),
              ),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (calculationResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  calculationResult,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String computeEnergyLoss(Map<String, double> values) {
  final omega = values['omega']!;
  final tV = values['tV']!;
  final pM = values['pM']!;
  final tM = values['tM']!;
  final kP = values['kP']!;
  final zPerA = values['zPerA']!;
  final zPerP = values['zPerP']!;

  final mWnedA = omega * tV * pM * tM;
  final mWnedP = kP * pM * tM;
  final mZper = zPerA * mWnedA + zPerP * mWnedP;

  return 'M(Wнед.а): ${mWnedA.toStringAsFixed(2)} (кВт * год)\n'
      'M(Wед.п): ${mWnedP.toStringAsFixed(2)} (кВт * год)\n'
      'M(Зпер): ${mZper.toStringAsFixed(2)} (грн)';
}

const Map<String, String> inputLabels = {
  'omega': 'Omega',
  'tV': 'tS',
  'pM': 'pM',
  'tM': 'tM',
  'kP': 'kP',
  'zPerA': 'zPerA',
  'zPerP': 'zPerP',
};
