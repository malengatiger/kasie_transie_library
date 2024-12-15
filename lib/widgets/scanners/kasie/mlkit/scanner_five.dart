import 'package:flutter/material.dart';

class ScannerFive extends StatefulWidget {
  const ScannerFive({super.key});

  @override
  ScannerFiveState createState() => ScannerFiveState();
}

class ScannerFiveState extends State<ScannerFive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
