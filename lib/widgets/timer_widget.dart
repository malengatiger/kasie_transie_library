import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key, required this.title, this.subTitle, this.isSmallSize})
      : super(key: key);

  final String title;
  final String? subTitle;
  final bool? isSmallSize;

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ TimerWidget: ❤️ ';

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
      width: widget.isSmallSize == null? 400: 300,
      height: widget.isSmallSize == null? 400: 600,
      child: Padding(
        padding:  EdgeInsets.all(widget.isSmallSize == null? 8:16.0),
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.all(widget.isSmallSize == null? 8: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   SizedBox(
                    height: widget.isSmallSize == null? 8: 32,
                  ),
                  Text(
                    widget.title,
                    style: myTextStyleMediumLargeWithColor(
                        context, Colors.grey.shade700, 16),
                  ),
                  SizedBox(
                    height: widget.isSmallSize == null? 8:32,
                  ),
                  widget.subTitle == null
                      ? const SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: widget.isSmallSize == null? 8:32.0),
                          child: Text(widget.subTitle!),
                        ),
                   SizedBox(
                    height: widget.isSmallSize == null? 4: 48,
                  ),
                  widget.isSmallSize == null? SizedBox(width: widget.isSmallSize == null? 72:120, height: widget.isSmallSize == null? 72:120,
                    child: AnalogClock(
                      dateTime: date,
                      isKeepTime: true,
                      child: const Align(
                        alignment: FractionalOffset(0.5, 0.75),
                        child: Text('GMT+2'),
                      ),
                    ),
                  ): gapW16,
                   SizedBox(
                    height: widget.isSmallSize == null? 8:48,
                  ),
                  Text(
                    getFormattedTime(timeInSeconds: elapsed),
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, widget.isSmallSize == null? 20:48),
                  ),
                   SizedBox(
                    height: widget.isSmallSize == null? 16:48,
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
