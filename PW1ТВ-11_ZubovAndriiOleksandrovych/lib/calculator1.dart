import 'package:flutter/material.dart';

/// Мапа назв елементів і відповідних полів введення
const Map<String, String> fuelComponents = {
  'hydrogen': 'Водень (H)%',
  'carbon': 'Вуглець (C)%',
  'sulfur': 'Сірка (S)%',
  'nitrogen': 'Азот (N)%',
  'oxygen': 'Кисень (O)%',
  'moisture': 'Волога (W)%',
  'ash': 'Зола (A)%'
};

/// Функція для розрахунків
String computeFuelData(Map<String, double> inputs) {
  final moisture = inputs['moisture']!;
  final dryMassRatio = 100 / (100 - moisture);
  final combustibleMassRatio = 100 / (100 - moisture - inputs['ash']!);

  final dryMass = inputs.map((key, value) => MapEntry(key, value * dryMassRatio));
  final combustibleMass =
  inputs.map((key, value) => MapEntry(key, value * combustibleMassRatio));

  final heatValueWorking = (339 * inputs['carbon']! +
      1030 * inputs['hydrogen']! -
      108.8 * (inputs['oxygen']! - inputs['sulfur']!) -
      25 * moisture) /
      1000;
  final heatValueDry = (heatValueWorking + 0.025 * moisture) * dryMassRatio;
  final heatValueCombustible = (heatValueWorking + 0.025 * moisture) * combustibleMassRatio;

  return 'Коефіцієнт переходу до сухої маси: ${dryMassRatio.toStringAsFixed(2)}\n\n'
      'Коефіцієнт переходу до горючої маси: ${combustibleMassRatio.toStringAsFixed(2)}\n\n'
      'Склад сухої маси:\n'
      'H: ${dryMass['hydrogen']?.toStringAsFixed(2)}%\n'
      'C: ${dryMass['carbon']?.toStringAsFixed(2)}%\n'
      'S: ${dryMass['sulfur']?.toStringAsFixed(2)}%\n'
      'N: ${dryMass['nitrogen']?.toStringAsFixed(2)}%\n'
      'O: ${dryMass['oxygen']?.toStringAsFixed(2)}%\n'
      'A: ${dryMass['ash']?.toStringAsFixed(2)}%\n\n'
      'Склад горючої маси:\n'
      'H: ${combustibleMass['hydrogen']?.toStringAsFixed(2)}%\n'
      'C: ${combustibleMass['carbon']?.toStringAsFixed(2)}%\n'
      'S: ${combustibleMass['sulfur']?.toStringAsFixed(2)}%\n'
      'N: ${combustibleMass['nitrogen']?.toStringAsFixed(2)}%\n'
      'O: ${combustibleMass['oxygen']?.toStringAsFixed(2)}%\n\n'
      'Нижча теплота згоряння:\n'
      '- Робоча маса: ${heatValueWorking.toStringAsFixed(4)} МДж/кг\n'
      '- Суха маса: ${heatValueDry.toStringAsFixed(4)} МДж/кг\n'
      '- Горюча маса: ${heatValueCombustible.toStringAsFixed(4)} МДж/кг';
}

class FuelCalculator extends StatefulWidget {
  const FuelCalculator({super.key});

  @override
  FuelCalculatorState createState() => FuelCalculatorState();
}

class FuelCalculatorState extends State<FuelCalculator> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in fuelComponents.keys) key: TextEditingController()
  };

  String resultText = '';
  String errorText = '';

  void performCalculation() {
    final inputValues = inputControllers.map(
            (key, controller) => MapEntry(key, double.tryParse(controller.text)));

    if (inputValues.values.any((v) => v == null)) {
      setState(() {
        resultText = '';
        errorText = 'Будь ласка, заповніть всі поля коректно.';
      });
      return;
    }

    final totalPercentage = inputValues.values.reduce((sum, value) => sum! + value!);
    if (totalPercentage != 100.0) {
      setState(() {
        resultText = '';
        errorText = 'Сума компонентів має дорівнювати 100%';
      });
      return;
    }

    final parsedInputs = inputValues.map((key, value) => MapEntry(key, value!));
    final computedResult = computeFuelData(parsedInputs);

    setState(() {
      resultText = computedResult;
      errorText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор Палива'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...inputControllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextField(
                controller: entry.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: fuelComponents[entry.key] ?? entry.key.toUpperCase(),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                onPressed: performCalculation,
                child: const Text('Обчислити'),
              ),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (resultText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  resultText,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
