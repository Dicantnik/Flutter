import 'package:flutter/material.dart';

class Calculator1 extends StatefulWidget {
  const Calculator1({super.key});

  @override
  Calculator1State createState() => Calculator1State();
}

class Calculator1State extends State<Calculator1> {
  final Map<String, TextEditingController> controllers = {
    for (var key in elementLabels.keys) key: TextEditingController()
  };

  String result = '';
  String errorMessage = '';

  void onCalculate() {
    final values = controllers.map(
            (key, controller) => MapEntry(key, double.tryParse(controller.text)));

    if (values.values.any((v) => v == null)) {
      setState(() {
        errorMessage = 'Будь ласка, заповніть всі поля коректно.';
        result = '';
      });
      return;
    }

    final parsedValues = values.map((key, value) => MapEntry(key, value!));
    final calculationResult = calculate(parsedValues);

    setState(() {
      result = calculationResult;
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Калькулятор Надійності',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF583E23),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: entry.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: elementLabels[entry.key],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Color(0xFF583E23), width: 2),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF583E23),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Обчислити',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDF8ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF583E23), width: 2),
                  ),
                  child: Text(
                    result,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
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

/// Структура даних для показників надійності
class ReliabilityIndicators {
  final double omega;
  final double tV;
  final double mu;
  final double tP;

  const ReliabilityIndicators(this.omega, this.tV, this.mu, this.tP);
}

const Map<String, ReliabilityIndicators> dataIndicators = {
  'ПЛ-110 кВ': ReliabilityIndicators(0.007, 10.0, 0.167, 35.0),
  'ПЛ-35 кВ': ReliabilityIndicators(0.02, 8.0, 0.167, 35.0),
  'ПЛ-10 кВ': ReliabilityIndicators(0.02, 10.0, 0.167, 35.0),
  'КЛ-10 кВ (траншея)': ReliabilityIndicators(0.03, 44.0, 1.0, 9.0),
  'КЛ-10 кВ (кабельний канал)': ReliabilityIndicators(0.005, 17.5, 1.0, 9.0),
  'T-110 кВ': ReliabilityIndicators(0.015, 100.0, 1.0, 43.0),
  'T-35 кВ': ReliabilityIndicators(0.02, 80.0, 1.0, 28.0),
  'T-10 кВ (кабельна мережа 10 кВ)':
  ReliabilityIndicators(0.005, 60.0, 0.5, 10.0),
  'T-10 кВ (повітряна мережа 10 кВ)':
  ReliabilityIndicators(0.05, 60.0, 0.5, 10.0),
  'B-110 кВ (елегазовий)': ReliabilityIndicators(0.01, 30.0, 0.1, 30.0),
  'B-10 кВ (малооливний)': ReliabilityIndicators(0.02, 15.0, 0.33, 15.0),
  'B-10 кВ (вакуумний)': ReliabilityIndicators(0.01, 15.0, 0.33, 15.0),
  'Збірні шини 10 кВ на 1 приєднання':
  ReliabilityIndicators(0.03, 2.0, 0.167, 5.0),
  'АВ-0,38 кВ': ReliabilityIndicators(0.05, 4.0, 0.33, 10.0),
  'ЕД 6,10 кВ': ReliabilityIndicators(0.1, 160.0, 0.5, 0.0),
  'ЕД 0,38 кВ': ReliabilityIndicators(0.1, 50.0, 0.5, 0.0),
};

/// Мапа назв елементів
const Map<String, String> elementLabels = {
  'pl110': 'ПЛ-110 кВ',
  'pl35': 'ПЛ-35 кВ',
  'pl10': 'ПЛ-10 кВ',
  'kl10t': 'КЛ-10 кВ (траншея)',
  'kl10c': 'КЛ-10 кВ (кабельний канал)',
  't110': 'T-110 кВ',
  't35': 'T-35 кВ',
  't10c': 'T-10 кВ (кабельна мережа 10 кВ)',
  't10p': 'T-10 кВ (повітряна мережа 10 кВ)',
  'b110': 'B-110 кВ (елегазовий)',
  'b10m': 'B-10 кВ (малооливний)',
  'b10v': 'B-10 кВ (вакуумний)',
  'bus10': 'Збірні шини 10 кВ на 1 приєднання',
  'av038': 'АВ-0,38 кВ',
  'ed610': 'ЕД 6,10 кВ',
  'ed038': 'ЕД 0,38 кВ',
};

/// Функція для обчислення
String calculate(Map<String, double> values) {
  double wOc = 0.0;
  double tVOc = 0.0;
  const totalHours = 8760;

  values.forEach((key, amount) {
    final indicator = dataIndicators[elementLabels[key]];
    if (indicator != null && amount > 0) {
      wOc += amount * indicator.omega;
      tVOc += amount * indicator.tV * indicator.omega;
    }
  });

  tVOc /= wOc;
  final kAOc = (tVOc * wOc) / totalHours;
  final kPOs = 1.2 * 43 / totalHours;
  final wDk = 2 * wOc * (kAOc + kPOs);

  return 'Wос = ${wOc.toStringAsFixed(4)} (рік⁻¹)\n'
      'tв.ос = ${tVOc.toStringAsFixed(2)} (год)\n'
      'kа.ос = ${kAOc.toStringAsFixed(5)}\n'
      'kп.ос = ${kPOs.toStringAsFixed(4)}\n'
      'Wдк = ${wDk.toStringAsFixed(4)} (рік⁻¹)\n'
      'Wдс = ${(wDk + 0.02).toStringAsFixed(4)} (рік⁻¹)';
}