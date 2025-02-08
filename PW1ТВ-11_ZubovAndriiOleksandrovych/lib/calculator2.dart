import 'package:flutter/material.dart';

/// Мапа назв елементів і полів введення
const Map<String, String> fuelOilComponents = {
  'hydrogen': 'Водень (H)%',
  'carbon': 'Вуглець (C)%',
  'sulfur': 'Сірка (S)%',
  'oxygen': 'Кисень (O)%',
  'moisture': 'Волога (W)%',
  'ash': 'Зола (A)%',
  'vanadium': 'Ванадій (V) мг/кг',
  'fuelOilHeat': 'Q мазуту (Q Fuel oil) МДж/кг',
};

/// Функція для розрахунків
String computeFuelOilData(Map<String, double> inputs) {
  final moisture = inputs['moisture']!;
  final ash = inputs['ash']!;
  final fuelOilHeat = inputs['fuelOilHeat']!;
  final krs = (100 - moisture - ash) / 100;

  final hWork = inputs['hydrogen']! * krs;
  final cWork = inputs['carbon']! * krs;
  final sWork = inputs['sulfur']! * krs;
  final oWork = inputs['oxygen']! * krs;
  final vWork = inputs['vanadium']! * (100 - moisture) / 100;

  final qR = fuelOilHeat * krs - 0.025 * moisture;

  return 'Склад робочої маси мазуту:\n'
      'C: ${cWork.toStringAsFixed(2)}%\n'
      'H: ${hWork.toStringAsFixed(2)}%\n'
      'S: ${sWork.toStringAsFixed(2)}%\n'
      'O: ${oWork.toStringAsFixed(2)}%\n'
      'A: ${ash.toStringAsFixed(2)}%\n'
      'V: ${vWork.toStringAsFixed(2)} (мг/кг)\n\n'
      'Нижча теплота згоряння: ${qR.toStringAsFixed(2)} (МДж/кг)';
}

class FuelOilCalculator extends StatefulWidget {
  const FuelOilCalculator({super.key});

  @override
  FuelOilCalculatorState createState() => FuelOilCalculatorState();
}

class FuelOilCalculatorState extends State<FuelOilCalculator> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in fuelOilComponents.keys) key: TextEditingController()
  };

  String resultText = '';
  String errorText = '';

  void performCalculation() {
    final inputValues = inputControllers.map(
            (key, controller) => MapEntry(key, double.tryParse(controller.text)));

    if (inputValues.values.any((v) => v == null)) {
      setState(() {
        errorText = 'Будь ласка, заповніть всі поля коректно.';
        resultText = '';
      });
      return;
    }

    final parsedInputs = inputValues.map((key, value) => MapEntry(key, value!));
    final computedResult = computeFuelOilData(parsedInputs);

    setState(() {
      resultText = computedResult;
      errorText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор Мазуту'),
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
                  labelText: fuelOilComponents[entry.key] ?? entry.key.toUpperCase(),
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
