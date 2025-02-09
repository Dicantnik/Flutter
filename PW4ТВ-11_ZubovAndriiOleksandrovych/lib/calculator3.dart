import 'package:flutter/material.dart';
import 'dart:math';

class PowerCalculator2 extends StatefulWidget {
  const PowerCalculator2({super.key});

  @override
  PowerCalculatorState createState() => PowerCalculatorState();
}

class PowerCalculatorState extends State<PowerCalculator2> {
  final Map<String, TextEditingController> inputControllers = {
    for (var key in inputLabels.keys) key: TextEditingController()
  };

  String calculationResult = '';
  String errorNotification = '';

  void computeResult() {
    final values = inputControllers.map(
          (key, controller) => MapEntry(key, double.tryParse(controller.text)),
    );

    if (values.values.any((v) => v == null)) {
      setState(() {
        errorNotification = 'Будь ласка, заповніть всі поля коректно.';
        calculationResult = '';
      });
      return;
    }

    final parsedValues = values.map((key, value) => MapEntry(key, value!));
    final computedResult = performCalculations(parsedValues);
    setState(() {
      calculationResult = computedResult;
      errorNotification = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор потужності'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: computeResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('Обчислити', style: TextStyle(fontSize: 18.0)),
              ),
            ),
            if (errorNotification.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorNotification,
                  style: const TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ),
            if (calculationResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  calculationResult,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const Map<String, String> inputLabels = {
  'Umax': 'Umax, кВ',
  'U_nom': 'U_nom, кВ',
  'U_norm': 'U_norm, кВ',
  'S_t': 'S_t, мВ*А',
  'R_cond': 'R_cond, Ом',
  'R_min': 'R_min, Ом',
  'X_cond': 'X_cond, Ом',
  'X_min': 'X_min, Ом',
  'L_length': 'L_length, км',
  'R_0': 'R_0, Ом',
  'X_0': 'X_0, Ом',
};
//
// final Umax = values['Umax']!;
// final U_nom = values['U_nom']!;
// final U_norm = values['U_norm']!;
// final S_t = values['S_t']!;
// final R_cond = values['R_cond']!;
// final R_min = values['R_min']!;
// final X_cond = values['X_cond']!;
// final X_min = values['X_min']!;
// final L_length = values['L_length']!;
// final R_0 = values['R_0']!;
// final X_0 = values['X_0']!;

/// Функція для обчислення результату
String performCalculations(Map<String, double> values) {
  final Uk_max = values['Umax']!;
  final Uv_n = values['U_nom']!;
  final Un_n = values['U_norm']!;
  final Snom_t = values['S_t']!;
  final Rc_n = values['R_cond']!;
  final Rc_min = values['R_min']!;
  final Xc_n = values['X_cond']!;
  final Xc_min = values['X_min']!;
  final L_l = values['L_length']!;
  final R_0 = values['R_0']!;
  final X_0 = values['X_0']!;

  final Xt = Uk_max * pow(Uv_n, 2) / 100 / Snom_t;
  final Rsh = Rc_n;
  final Xsh = Xc_n + Xt;
  final Zsh = sqrt(pow(Rsh, 2) + pow(Xsh, 2));
  final Rsh_min = Rc_min;
  final Xsh_min = Xc_min + Xt;
  final Zsh_min = sqrt(pow(Rsh_min, 2) + pow(Xsh_min, 2));

  final Ish3 = Uv_n * 1000 / sqrt(3.0) / Zsh;
  final Ish2 = Ish3 * sqrt(3.0) / 2;
  final Ish_min3 = Uv_n * 1000 / sqrt(3.0) / Zsh_min;
  final Ish_min2 = Ish_min3 * sqrt(3.0) / 2;

  final kpr = pow(Un_n, 2) / pow(Uv_n, 2);

  final Rsh_n = Rsh * kpr;
  final Xsh_n = Xsh * kpr;
  final Zsh_n = sqrt(pow(Rsh_n, 2) + pow(Xsh_n, 2));
  final Rsh_n_min = Rsh_min * kpr;
  final Xsh_n_min = Xsh_min * kpr;
  final Zsh_n_min = sqrt(pow(Rsh_n_min, 2) + pow(Xsh_n_min, 2));

  final Ish_n3 = Un_n * 1000 / sqrt(3.0) / Zsh_n;
  final Ish_n2 = Ish_n3 * sqrt(3.0) / 2;
  final Ish_n_min3 = Un_n * 1000 / sqrt(3.0) / Zsh_n_min;
  final Ish_n_min2 = Ish_n_min3 * sqrt(3.0) / 2;

  final R_l = L_l * R_0;
  final X_l = L_l * X_0;

  final R_sum_n = R_l + Rsh_n;
  final X_sum_n = X_l + Xsh_n;
  final Z_sum_n = sqrt(pow(R_sum_n, 2) + pow(X_sum_n, 2));

  final R_sum_n_min = R_l + Rsh_n_min;
  final X_sum_n_min = X_l + Xsh_n_min;
  final Z_sum_n_min = sqrt(pow(R_sum_n_min, 2) + pow(X_sum_n_min, 2));

  final I_l_n3 = Un_n * 1000 / sqrt(3.0) / Z_sum_n;
  final I_l_n2 = I_l_n3 * sqrt(3.0) / 2;
  final I_l_n_min3 = Un_n * 1000 / sqrt(3.0) / Z_sum_n_min;
  final I_l_n_min2 = I_l_n_min3 * sqrt(3.0) / 2;

  return "Xт: ${Xt.toStringAsFixed(2)} (Ом)\n"
      "Rш: ${Rsh.toStringAsFixed(2)} (Ом)\n"
      "Xш: ${Xsh.toStringAsFixed(2)} (Ом)\n"
      "Zщ: ${Zsh.toStringAsFixed(2)} (Ом)\n"
      "Rщ_min: ${Rsh_min.toStringAsFixed(2)} (Ом)\n"
      "Xш_min: ${Xsh_min.toStringAsFixed(2)} (Ом)\n"
      "Zш_min: ${Zsh_min.toStringAsFixed(2)} (Ом)\n"
      "I3ш: ${Ish3.toStringAsFixed(2)} (А)\n"
      "I2ш: ${Ish2.toStringAsFixed(2)} (А)\n"
      "I3ш_min: ${Ish_min3.toStringAsFixed(2)} (А)\n"
      "I2ш_min: ${Ish_min2.toStringAsFixed(2)} (А)\n"
      "kпр: ${kpr.toStringAsFixed(2)}\n"
      "Rшн: ${Rsh_n.toStringAsFixed(2)} (Ом)\n"
      "Xшн: ${Xsh_n.toStringAsFixed(2)} (Ом)\n"
      "Zшн: ${Zsh_n.toStringAsFixed(2)} (Ом)\n"
      "Rшн_min: ${Rsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "Xшн_min: ${Xsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "Zшн_min: ${Zsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "I3шн: ${Ish_n3.toStringAsFixed(2)} (А)\n"
      "I2шн: ${Ish_n2.toStringAsFixed(2)} (А)\n"
      "I3шн_min: ${Ish_n_min3.toStringAsFixed(2)} (А)\n"
      "I2шн_min: ${Ish_n_min2.toStringAsFixed(2)} (А)\n"
      "Rл: ${R_l.toStringAsFixed(2)} (Ом)\n"
      "Xл: ${X_l.toStringAsFixed(2)} (Ом)\n"
      "RΣн: ${R_sum_n.toStringAsFixed(2)} (Ом)\n"
      "XΣн: ${X_sum_n.toStringAsFixed(2)} (Ом)\n"
      "ZΣн: ${Z_sum_n.toStringAsFixed(2)} (Ом)\n"
      "RΣн_min: ${R_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "XΣn_min: ${X_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "ZΣn_min: ${Z_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "I3лн: ${I_l_n3.toStringAsFixed(2)} (А)\n"
      "I2лн: ${I_l_n2.toStringAsFixed(2)} (А)\n"
      "I3лн_min: ${I_l_n_min3.toStringAsFixed(2)} (А)\n"
      "I2лн_min: ${I_l_n_min2.toStringAsFixed(2)} (А)\n";
}
