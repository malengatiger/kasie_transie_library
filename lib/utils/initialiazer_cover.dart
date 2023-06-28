import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initializer.dart';

class InitializerCover extends StatefulWidget {
  const InitializerCover({Key? key}) : super(key: key);

  @override
  InitializerCoverState createState() => InitializerCoverState();
}

class InitializerCoverState extends State<InitializerCover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool busy = true;
  late Timer timer;
  late StreamSubscription<bool> completionSub;
  final mm = '😡😡😡😡😡😡😡 InitializerCover 😡 ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _init();
    _listen();
  }

  int elapsed = 0;
  bool timerTicking = false;
  void _listen() {
    completionSub = initializer.completionStream.listen((isComplete) {
      pp('\n\n$mm ... delivered completion flag: $isComplete');
      if (mounted) {
        pp('$mm ... leaving the stage - popping out! \n\n');
        Navigator.of(context).pop(true);
      }
    });
  }
  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsed = timer.tick;
        timerTicking = true;
      });
    });
  }
  void _init() async {
    try {
      setState(() {
        busy = true;
      });
      _startTimer();
      await initializer.initialize();
    } catch (e) {
      pp(e);
      showSnackBar(
          padding: 16,
          backgroundColor: Colors.pink[400],
          textStyle: myTextStyleMediumBlack(context),
          message: 'Error initializing data',
          context: context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = getFormattedTime(timeInSeconds: elapsed);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Text(
          'Kasie Transie Loader',
          style: myTextStyleLarge(context),
        ),
      ),
      body: busy
          ? Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Card(
                  shape: getRoundedBorder(radius: 16),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 64,
                        ),
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            backgroundColor: Colors.indigo,
                          ),
                        ),
                        const SizedBox(
                          height: 64,
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Time Elapsed: '),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              m,
                              style: myTextStyleLargePrimaryColor(context),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text('Loading association data from the Mother Ship', style: myTextStyleSmallBold(context),)
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
    ));
  }
}
