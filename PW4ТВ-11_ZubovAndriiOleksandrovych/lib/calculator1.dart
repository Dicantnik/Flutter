import 'package:flutter/material.dart';
import 'dart:math';

class ElectricalCalculator extends StatefulWidget {
  const ElectricalCalculator({super.key});

  @override
  ElectricalCalculatorState createState() => ElectricalCalculatorState();
}

enum ConductorType {
  unshielded('Неізольовані проводи та шини'),
  paperRubberCables('Кабелі з паперовою та гумовою ізоляцією'),
  rubberPlasticCables('Кабелі з гумовою та пластмасовою ізоляцією');

  final String displayName;
  const ConductorType(this.displayName);
}

enum ConductorMaterial {
  copper('Мідь'),
  aluminum('Алюміній');

  final String displayName;
  const ConductorMaterial(this.displayName);
}

class ElectricalCalculatorState extends State<ElectricalCalculator> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in inputLabels.keys) key: TextEditingController()
  };

  ConductorType selectedType = ConductorType.unshielded;
  ConductorMaterial selectedMaterial = ConductorMaterial.aluminum;

  String calculationResult = "";
  String errorText = "";

  void performCalculation() {
    final values = inputControllers.map(
          (key, controller) => MapEntry(key, double.tryParse(controller.text)),
    );

    if (values.values.any((v) => v == null)) {
      setState(() {
        errorText = 'Будь ласка, заповніть всі поля коректно.';
        calculationResult = '';
      });
      return;
    }

    final parsedValues = values.map((key, value) => MapEntry(key, value!));
    final conductorSpecs = {'type': selectedType, 'material': selectedMaterial};

    setState(() {
      calculationResult = calculateResult(parsedValues, conductorSpecs);
      errorText = '';
    });
  }

  String calculateResult(Map<String, double> values, Map<String, dynamic> conductorSpecs) {
    double Unom = values['Unom']!;
    double Sm = values['Sm']!;
    double Ik = values['Ik']!;
    double Tf = values['Tf']!;
    double Tm = values['Tm']!;
    double Ct = values['Ct']!;

    ConductorType type = conductorSpecs['type'] as ConductorType;
    ConductorMaterial material = conductorSpecs['material'] as ConductorMaterial;

    double current = Sm / (2.0 * sqrt(3.0) * Unom);
    double doubleCurrent = 2 * current;
    double jekValue = fetchJekValue(type, material, Tm);
    double section = jekValue > 0.0 ? current / jekValue : 0.0;
    double minSection = Ik * 1000 * sqrt(Tf) / Ct;

    return "Iм: ${current.toStringAsFixed(2)} (A)\n"
        "Iм.па: ${doubleCurrent.toStringAsFixed(2)} (A)\n"
        "Sек: ${section.toStringAsFixed(2)} (мм²)\n"
        "Smin: ${minSection.toStringAsFixed(2)} (мм²)";
  }

  double fetchJekValue(ConductorType type, ConductorMaterial material, double Tm) {
    final Map<ConductorType, Map<ConductorMaterial, List<MapEntry<RangeValues, double>>>> jekValues = {
      ConductorType.unshielded: {
        ConductorMaterial.copper: [
          MapEntry(RangeValues(1000, 3000), 2.5),
          MapEntry(RangeValues(3000, 5000), 2.1),
          MapEntry(RangeValues(5000, double.infinity), 1.8),
        ],
        ConductorMaterial.aluminum: [
          MapEntry(RangeValues(1000, 3000), 1.3),
          MapEntry(RangeValues(3000, 5000), 1.1),
          MapEntry(RangeValues(5000, double.infinity), 1.0),
        ],
      },
      ConductorType.paperRubberCables: {
        ConductorMaterial.copper: [
          MapEntry(RangeValues(1000, 3000), 3.0),
          MapEntry(RangeValues(3000, 5000), 2.5),
          MapEntry(RangeValues(5000, double.infinity), 2.0),
        ],
        ConductorMaterial.aluminum: [
          MapEntry(RangeValues(1000, 3000), 1.6),
          MapEntry(RangeValues(3000, 5000), 1.4),
          MapEntry(RangeValues(5000, double.infinity), 1.2),
        ],
      },
      ConductorType.rubberPlasticCables: {
        ConductorMaterial.copper: [
          MapEntry(RangeValues(1000, 3000), 3.5),
          MapEntry(RangeValues(3000, 5000), 3.1),
          MapEntry(RangeValues(5000, double.infinity), 2.7),
        ],
        ConductorMaterial.aluminum: [
          MapEntry(RangeValues(1000, 3000), 1.9),
          MapEntry(RangeValues(3000, 5000), 1.7),
          MapEntry(RangeValues(5000, double.infinity), 1.6),
        ],
      },
    };
    return jekValues[type]?[material]?.firstWhere(
          (entry) => Tm >= entry.key.start && Tm <= entry.key.end,
      orElse: () => MapEntry(RangeValues(0, 0), 0),
    ).value ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Електричний калькулятор')),
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
                  ),
                ),
              );
            }),
            DropdownButton<ConductorType>(
              value: selectedType,
              items: ConductorType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value!),
            ),
            DropdownButton<ConductorMaterial>(
              value: selectedMaterial,
              items: ConductorMaterial.values.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: Text(material.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedMaterial = value!),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: performCalculation,
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


const Map<String, String> inputLabels = {
  'Unom': 'Unom, кВ',
  'Sm': 'Sm, кВт*А',
  'Ik': 'Ik, кА',
  'P_TP': 'P_TP, кВ*А',
  'Tf': 'Tf, с',
  'Tm': 'Tm, год',
  'Ct': 'Ст',
};
