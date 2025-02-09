import 'package:flutter/material.dart';
import 'dart:math';

class EquipmentCalculator extends StatefulWidget {
  const EquipmentCalculator({super.key});

  @override
  _EquipmentCalculatorState createState() => _EquipmentCalculatorState();
}

class _EquipmentCalculatorState extends State<EquipmentCalculator> {
  // Список обладнання (переіменовано з equipmentList)
  List<Device> deviceList = [
    Device("Шліфувальний верстат", "0.92", "0.9", "0.38", "4", "20", "0.15", "1.33"),
    Device("Свердлильний верстат", "0.92", "0.9", "0.38", "2", "14", "0.12", "1"),
    Device("Фугувальний верстат", "0.92", "0.9", "0.38", "4", "42", "0.15", "1.33"),
    Device("Циркулярна пила", "0.92", "0.9", "0.38", "1", "36", "0.3", "1.52"),
    Device("Прес", "0.92", "0.9", "0.38", "1", "20", "0.5", "0.75"),
    Device("Полірувальний верстат", "0.92", "0.9", "0.38", "1", "40", "0.2", "1"),
    Device("Фрезерний верстат", "0.92", "0.9", "0.38", "2", "32", "0.2", "1"),
    Device("Вентилятор", "0.92", "0.9", "0.38", "1", "20", "0.65", "0.75"),
  ];

  // Параметри для розрахунків (переіменовано для покращення читабельності)
  double totalNominalPowerWithCoeff = 0.0;
  String activePowerCoeff = "1.25";
  String secondaryActivePowerCoeff = "0.7";
  String groupUtilizationCoef = "";
  String effectiveDeviceCount = "";
  String overallDeptUtilizationCoef = "";
  String effectiveDeptDeviceCount = "";
  String deptActivePower = "";
  String deptReactivePower = "";
  String deptApparentPower = "";
  String deptCurrent = "";
  String busActivePower = "";
  String busReactivePower = "";
  String busApparentPower = "";
  String busCurrent = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор ЕП'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кнопка для додавання нового обладнання
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  deviceList.add(Device());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Додати обладнання"),
            ),
            const SizedBox(height: 16),
            // Відображення полів введення для кожного пристрою
            ...deviceList.map(
                  (device) => DeviceInputCard(
                device: device,
                onUpdate: (updatedDevice) {
                  setState(() {
                    int index = deviceList.indexOf(device);
                    deviceList[index] = updatedDevice;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Поля введення коефіцієнтів розрахунку
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: activePowerCoeff),
                      onChanged: (value) {
                        setState(() {
                          activePowerCoeff = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Коеф. активної потужності (Kr)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: secondaryActivePowerCoeff),
                      onChanged: (value) {
                        setState(() {
                          secondaryActivePowerCoeff = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Коеф. активної потужності (Kr2)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка розрахунку
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateResults,
                child: const Text('Обчислити'),
              ),
            ),
            const SizedBox(height: 16),
            // Вивід результатів групового коефіцієнта та ефективної кількості обладнання
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Груповий коеф. використання: $groupUtilizationCoef\n"
                      "Ефективна кількість обладнання: $effectiveDeviceCount",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Вивід результатів розрахунку потужностей та струмів для цеху
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Розрахункове активне навантаження: $deptActivePower (кВт)\n"
                      "Розрахункове реактивне навантаження: $deptReactivePower (квар)\n"
                      "Повна потужність: $deptApparentPower (кВА)\n"
                      "Розрахунковий груповий струм: $deptCurrent (А)\n"
                      "Коеф. використання цеху: $overallDeptUtilizationCoef\n"
                      "Ефективна кількість обладнання в цеху: $effectiveDeptDeviceCount",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Вивід результатів розрахунку для шин трансформаторної підстанції
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Активне навантаження на шинах 0,38 кВ ТП: $busActivePower (кВт)\n"
                      "Реактивне навантаження на шинах 0,38 кВ ТП: $busReactivePower (квар)\n"
                      "Повна потужність на шинах 0,38 кВ ТП: $busApparentPower (кВА)\n"
                      "Груповий струм на шинах 0,38 кВ ТП: $busCurrent (А)",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод розрахунку, який зберігає логіку вихідного коду
  void _calculateResults() {
    double sumPowerCoeffProduct = 0.0;
    double sumNominalPower = 0.0;
    double sumPowerSquared = 0.0;

    for (var device in deviceList) {
      double qty = double.tryParse(device.quantity) ?? 0.0;
      double nominal = double.tryParse(device.nominalPower) ?? 0.0;
      double deviceTotalPower = qty * nominal;
      device.totalNominalPower = deviceTotalPower.toString();

      double voltage = double.tryParse(device.voltage) ?? 0.0;
      double powerFactor = double.tryParse(device.powerFactor) ?? 0.0;
      double efficiency = double.tryParse(device.efficiency) ?? 0.0;
      // Обчислення струму для даного обладнання
      double currentCalculated = (deviceTotalPower) /
          (sqrt(3.0) * voltage * powerFactor * efficiency);
      device.current = currentCalculated.toString();

      double usageCoef = double.tryParse(device.usageCoefficient) ?? 0.0;
      sumPowerCoeffProduct += deviceTotalPower * usageCoef;
      sumNominalPower += deviceTotalPower;
      sumPowerSquared += qty * pow(nominal, 2);
    }

    totalNominalPowerWithCoeff = sumPowerCoeffProduct;

    // Груповий коефіцієнт використання
    double groupCoef = (sumNominalPower != 0) ? sumPowerCoeffProduct / sumNominalPower : 0;
    groupUtilizationCoef = groupCoef.toStringAsFixed(2);

    // Ефективна кількість обладнання
    double effectiveCount = (sumPowerSquared != 0)
        ? (pow(sumNominalPower, 2) / sumPowerSquared).ceilToDouble()
        : 0;
    effectiveDeviceCount = effectiveCount.toStringAsFixed(0);

    // Розрахунок потужностей та струмів для цеху
    double loadCoef = double.tryParse(activePowerCoeff) ?? 0.0;
    double voltageLevel = 0.38;
    double referencePower = 29.0;
    double tanPhi = 1.65;

    double activePower = loadCoef * totalNominalPowerWithCoeff;
    double reactivePower = groupCoef * referencePower * tanPhi;
    double apparentPower = sqrt(pow(activePower, 2) + pow(reactivePower, 2));
    double groupCurrent = activePower / voltageLevel;

    deptActivePower = activePower.toStringAsFixed(2);
    deptReactivePower = reactivePower.toStringAsFixed(2);
    deptApparentPower = apparentPower.toStringAsFixed(2);
    deptCurrent = groupCurrent.toStringAsFixed(2);

    overallDeptUtilizationCoef = (752.0 / 2330.0).toStringAsFixed(2);
    effectiveDeptDeviceCount = (pow(2330.0, 2) / 96399.0).toStringAsFixed(0);

    // Розрахунок навантаження на шинах ТП
    double secondaryCoef = double.tryParse(secondaryActivePowerCoeff) ?? 0.0;
    double busActive = secondaryCoef * 752.0;
    double busReactive = secondaryCoef * 657.0;
    double busApparent = sqrt(pow(busActive, 2) + pow(busReactive, 2));
    double busGrpCurrent = busActive / 0.38;

    busActivePower = busActive.toStringAsFixed(2);
    busReactivePower = busReactive.toStringAsFixed(2);
    busApparentPower = busApparent.toStringAsFixed(2);
    busCurrent = busGrpCurrent.toStringAsFixed(2);

    setState(() {});
  }
}

class Device {
  String name;
  String efficiency;
  String powerFactor;
  String voltage;
  String quantity;
  String nominalPower;
  String usageCoefficient;
  String reactivePowerFactor;
  String totalNominalPower;
  String current;

  Device([
    this.name = "",
    this.efficiency = "",
    this.powerFactor = "",
    this.voltage = "",
    this.quantity = "",
    this.nominalPower = "",
    this.usageCoefficient = "",
    this.reactivePowerFactor = "",
    this.totalNominalPower = "",
    this.current = "",
  ]);

  Device copyWith({
    String? name,
    String? efficiency,
    String? powerFactor,
    String? voltage,
    String? quantity,
    String? nominalPower,
    String? usageCoefficient,
    String? reactivePowerFactor,
    String? totalNominalPower,
    String? current,
  }) {
    return Device(
      name ?? this.name,
      efficiency ?? this.efficiency,
      powerFactor ?? this.powerFactor,
      voltage ?? this.voltage,
      quantity ?? this.quantity,
      nominalPower ?? this.nominalPower,
      usageCoefficient ?? this.usageCoefficient,
      reactivePowerFactor ?? this.reactivePowerFactor,
      totalNominalPower ?? this.totalNominalPower,
      current ?? this.current,
    );
  }
}

class DeviceInputCard extends StatelessWidget {
  final Device device;
  final Function(Device) onUpdate;

  const DeviceInputCard({
    super.key,
    required this.device,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final inputFields = [
      {
        'label': 'Найменування обладнання',
        'value': device.name,
        'onChanged': (value) => onUpdate(device.copyWith(name: value)),
      },
      {
        'label': 'ККД (ηн)',
        'value': device.efficiency,
        'onChanged': (value) => onUpdate(device.copyWith(efficiency: value)),
      },
      {
        'label': 'Коеф. потужності (cos φ)',
        'value': device.powerFactor,
        'onChanged': (value) => onUpdate(device.copyWith(powerFactor: value)),
      },
      {
        'label': 'Напруга (Uн, кВ)',
        'value': device.voltage,
        'onChanged': (value) => onUpdate(device.copyWith(voltage: value)),
      },
      {
        'label': 'Кількість (n)',
        'value': device.quantity,
        'onChanged': (value) => onUpdate(device.copyWith(quantity: value)),
      },
      {
        'label': 'Номінальна потужність (Рн, кВт)',
        'value': device.nominalPower,
        'onChanged': (value) => onUpdate(device.copyWith(nominalPower: value)),
      },
      {
        'label': 'Коеф. використання (КВ)',
        'value': device.usageCoefficient,
        'onChanged': (value) => onUpdate(device.copyWith(usageCoefficient: value)),
      },
      {
        'label': 'Коеф. реактивної потужності (tg φ)',
        'value': device.reactivePowerFactor,
        'onChanged': (value) =>
            onUpdate(device.copyWith(reactivePowerFactor: value)),
      },
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: inputFields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: TextEditingController(text: field['value'] as String?),
                onChanged: field['onChanged'] as void Function(String),
                decoration: InputDecoration(
                  labelText: field['label'] as String,
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
