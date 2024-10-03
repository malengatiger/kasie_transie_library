import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';

//todo - listen for progress on long downloads ...
class TimerWidget extends StatefulWidget {
  const TimerWidget(
      {super.key,
      required this.title,
      this.subTitle,
      required this.isSmallSize,
      this.listenForProgress});

  final String title;
  final String? subTitle;
  final bool isSmallSize;
  final bool? listenForProgress;

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ TimerWidget: ❤️ ';

  //todo - create subscriptions
  late Timer timer;
  int elapsed = 0;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    startTimer();
  }

  void startTimer() {
    pp('$mm ... timer starting ....');
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      elapsed = timer.tick;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return SizedBox(
      width: widget.isSmallSize ? 300 : 400,
      height: widget.isSmallSize ? 400 : 500,
      child: Padding(
        padding: EdgeInsets.all(widget.isSmallSize ? 8 : 12.0),
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(widget.isSmallSize ? 8 : 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: widget.isSmallSize ? 16 : 24,
                  ),
                  Text(
                    widget.title,
                    style: myTextStyleMediumLargeWithColor(
                        context, Colors.grey.shade700, 16),
                  ),
                  SizedBox(
                    height: widget.isSmallSize ? 16 : 24,
                  ),
                  widget.subTitle == null
                      ? const SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.isSmallSize ? 8 : 32.0),
                          child: Text(widget.subTitle!),
                        ),
                  SizedBox(
                    height: widget.isSmallSize ? 48 : 64,
                  ),
                  SizedBox(
                    width: widget.isSmallSize ? 84 : 128,
                    height: widget.isSmallSize ? 84 : 100,
                    child: AnalogClock(
                      dateTime: date,
                      isKeepTime: true,
                      child: const Align(
                        alignment: FractionalOffset(0.5, 0.75),
                        child: Text('GMT+2'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: widget.isSmallSize ? 48 : 64,
                  ),
                  Text(
                    getFormattedTime(timeInSeconds: elapsed),
                    style: myTextStyleMediumLargeWithColor(
                        context,
                        Theme.of(context).primaryColor,
                        widget.isSmallSize ? 28 : 32),
                  ),
                  SizedBox(
                    height: widget.isSmallSize ? 16 : 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
