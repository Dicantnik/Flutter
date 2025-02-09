import 'package:flutter/material.dart';

/// Мапа для елементів і назв інпутів
const Map<String, String> inputLabels = {
  'energyContent': 'Q_i_r',
  'airFactor': 'a_vun',
  'surfaceArea': 'A_r',
  'gasFactor': 'G_vun',
  'efficiencyLoss': 'eta_z_y',
  'correctionFactor': 'k_tv_s',
  'biomass': 'B',
};

/// Функція для обчислення результату
String calculateResult(Map<String, double> inputs) {
  final energyContent = inputs['energyContent']!;
  final airFactor = inputs['airFactor']!;
  final surfaceArea = inputs['surfaceArea']!;
  final gasFactor = inputs['gasFactor']!;
  final efficiencyLoss = inputs['efficiencyLoss']!;
  final correctionFactor = inputs['correctionFactor']!;
  final biomass = inputs['biomass']!;

  final emissionFactor = (1e6 / energyContent) * (airFactor * (surfaceArea / (100 - gasFactor)) * (1 - efficiencyLoss)) + correctionFactor;
  final totalEmission = 1e-6 * emissionFactor * energyContent * biomass;

  return 'Показник емісії: ${emissionFactor.toStringAsFixed(2)} (г/ГДж)\n'
      'Валовий викид: ${totalEmission.toStringAsFixed(2)} (т)';
}

class EmissionCalculator extends StatefulWidget {
  const EmissionCalculator({super.key});

  @override
  EmissionCalculatorState createState() => EmissionCalculatorState();
}

class EmissionCalculatorState extends State<EmissionCalculator> {
  final Map<String, TextEditingController> controllers = {
    for (var key in inputLabels.keys) key: TextEditingController()
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
        title: const Text('Калькулятор Викидів'),
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
