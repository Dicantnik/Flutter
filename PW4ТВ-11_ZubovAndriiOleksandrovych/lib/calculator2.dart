import 'package:flutter/material.dart';
import 'dart:math';

class PowerCalculator extends StatefulWidget {
  const PowerCalculator({super.key});

  @override
  PowerCalculatorState createState() => PowerCalculatorState();
}

class PowerCalculatorState extends State<PowerCalculator> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in inputLabels.keys) key: TextEditingController()
  };

  String outputResult = '';
  String validationMessage = '';

  void calculateResults() {
    final inputValues = inputControllers.map(
          (key, controller) => MapEntry(key, double.tryParse(controller.text)),
    );

    if (inputValues.values.any((value) => value == null)) {
      setState(() {
        validationMessage = 'Будь ласка, заповніть всі поля коректно.';
        outputResult = '';
      });
      return;
    }

    final parsedValues = inputValues.map((key, value) => MapEntry(key, value!));
    final computedResult = compute(parsedValues);

    setState(() {
      outputResult = computedResult;
      validationMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор Потужності'),
        backgroundColor: Color(0xFF583E23),
      ),
      body: Container(
        color: Color(0xFFFDF8ED),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...inputLabels.keys.map(
                    (key) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: inputControllers[key],
                    decoration: InputDecoration(
                      labelText: inputLabels[key],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: calculateResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF583E23),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Обчислити', style: TextStyle(fontSize: 18.0)),
                ),
              ),
              if (validationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    validationMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16.0),
                  ),
                ),
              if (outputResult.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        outputResult,
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Мапа назв для вводу даних
const Map<String, String> inputLabels = {
  "Voltage": "Ucn, кВ",
  "ShortCircuitPower": "Sk, МВ*А",
  "TransformerImpedance": "Uk_perc, %",
  "TransformerPower": "S_nom_t, МВ*А",
};

/// Функція для розрахунку параметрів
String compute(Map<String, double> values) {
  final voltage = values["Voltage"]!;
  final shortCircuitPower = values["ShortCircuitPower"]!;
  final transformerImpedance = values["TransformerImpedance"]!;
  final transformerPower = values["TransformerPower"]!;

  final Xc = pow(voltage, 2) / shortCircuitPower;
  final Xt = transformerImpedance * pow(voltage, 2) / transformerPower / 100;
  final X_sum = Xc + Xt;
  final Ip0 = voltage / (sqrt(3.0) * X_sum);

  return "Xс: ${Xc.toStringAsFixed(2)} Ом\n"
      "Xт: ${Xt.toStringAsFixed(2)} Ом\n"
      "XΣ: ${X_sum.toStringAsFixed(2)} Ом\n"
      "Iп0: ${Ip0.toStringAsFixed(2)} кА";
}