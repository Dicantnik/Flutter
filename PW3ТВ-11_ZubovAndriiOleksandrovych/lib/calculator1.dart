import 'package:flutter/material.dart';
import 'dart:math';

/// Мапа для елементів і назв інпутів
const Map<String, String> inputLabels = {
  'averagePower': 'Середньодобова потужність, (МВт)',
  'stdDeviation': 'Cередньоквадратичне відхилення, (МВт)',
  'energyCost': 'Вартість електроенергії, (грн/кВт*год)',
};

/// Функція для обчислення результату
String calculateResult(Map<String, double> inputs) {
  final averagePower = inputs['averagePower']!;
  final stdDeviation = inputs['stdDeviation']!;
  final energyCost = inputs['energyCost']!;

  final balancedEnergyShare = integrateEnergyShare(
    function: (power) => calculateNormalDistribution(power, averagePower, stdDeviation),
    averagePower: averagePower,
    totalSteps: 10000,
  );

  final revenue = averagePower * 24 * balancedEnergyShare * energyCost;
  final fine = averagePower * 24 * (1 - balancedEnergyShare) * energyCost;
  final profit = revenue - fine;

  return 'Дохід: ${revenue.toStringAsFixed(1)} (тис. грн)\n'
      'Штраф: ${fine.toStringAsFixed(1)} (тис. грн)\n'
      'Прибуток${profit < 0 ? ' (збиток)' : ''}: ${profit.toStringAsFixed(1)} (тис. грн)';
}

/// Обчислення значення функції нормального розподілу
double calculateNormalDistribution(
    double power, double averagePower, double stdDeviation) {
  return (1 / (stdDeviation * sqrt(2 * pi))) *
      exp(-(pow((power - averagePower), 2)) / (2 * pow(stdDeviation, 2)));
}

/// Обчислення інтегралу функції нормального розподілу
double integrateEnergyShare({
  required Function(double) function,
  required double averagePower,
  required int totalSteps,
  double deviationFactor = 0.05,
}) {
  final lowerLimit = averagePower * (1 - deviationFactor);
  final upperLimit = averagePower * (1 + deviationFactor);
  final stepSize = (upperLimit - lowerLimit) / totalSteps;
  double result = 0.0;

  for (int i = 0; i < totalSteps; i++) {
    final currentPoint = lowerLimit + i * stepSize;
    final nextPoint = currentPoint + stepSize;
    result += 0.5 * (function(currentPoint) + function(nextPoint)) * stepSize;
  }

  return result;
}

class EnergyCalculator extends StatefulWidget {
  const EnergyCalculator({super.key});

  @override
  EnergyCalculatorState createState() => EnergyCalculatorState();
}

class EnergyCalculatorState extends State<EnergyCalculator> {
  final Map<String, TextEditingController> controllers = {
    for (var key in inputLabels.keys) key: TextEditingController(),
  };

  String result = '';
  String errorText = '';

  void calculate() {
    final values = controllers.map(
            (key, controller) => MapEntry(key, double.tryParse(controller.text)));

    if (values.values.any((v) => v == null)) {
      setState(() {
        errorText = 'Будь ласка, заповніть всі поля коректно.';
        result = '';
      });
      return;
    }

    final parsedValues = values.map((key, value) => MapEntry(key, value!));
    final calculationResult = calculateResult(parsedValues);

    setState(() {
      result = calculationResult;
      errorText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF8ED),
      appBar: AppBar(
        title: const Text('Калькулятор Енергії'),
        backgroundColor: Color(0xFF583E23),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextField(
                controller: entry.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: inputLabels[entry.key] ?? entry.key.toUpperCase(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF583E23)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF583E23)),
                ),
                cursorColor: Color(0xFF583E23),
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF583E23),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Обчислити',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            if (result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      result,
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
