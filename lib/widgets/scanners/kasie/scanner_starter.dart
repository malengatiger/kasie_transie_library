import 'package:flutter/material.dart';

import 'kasie_ai_scanner.dart';

class ScannerStarter extends StatefulWidget {
  const ScannerStarter({super.key});

  @override
  ScannerStarterState createState() => ScannerStarterState();
}

class ScannerStarterState extends State<ScannerStarter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  Map<String, dynamic>? scanResult;
  Widget resultWidget = const SizedBox();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToScanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => KasieAIScanner(onScanned: (json) {
                if (json['vehicleId'] != null) {
                  resultWidget = VehicleScanned(json: json);
                }
                setState(() {
                  scanResult = json;
                });
              })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Row(
        children: [
          Icon(Icons.document_scanner_sharp),
          SizedBox(width: 16),
          Text(
            'KasieTransie AI Scanner Starter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ],
      )),
      body: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style:
                      const ButtonStyle(elevation: WidgetStatePropertyAll(8)),
                  child: const Text('Scan QR Code',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                  onPressed: () async {
                    _navigateToScanner();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            resultWidget,
          ],
        )
      ]),
    );
  }
}

class VehicleScanned extends StatelessWidget {
  const VehicleScanned({super.key, required this.json});
  final Map<String, dynamic> json;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Vehicle Scanned'),
          const SizedBox(
            height: 16,
          ),
          Text(
            json['vehicleReg'],
            style: const TextStyle(
                color: Colors.pink, fontSize: 36, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ));
  }
}
