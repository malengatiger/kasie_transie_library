import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initializer.dart';


class InitializerCover extends StatefulWidget {
  const InitializerCover(
      {Key? key, required this.onInitializationComplete, required this.onError})
      : super(key: key);

  final Function onInitializationComplete;
  final Function onError;
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
    _listen();
    _init();
  }

  int elapsed = 0;

  void _listen() {
    completionSub = initializer.completionStream.listen((isComplete) {
      pp('\n\n$mm ............. delivered completion flag: $isComplete');
      timer.cancel();
      widget.onInitializationComplete();

    });
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsed = timer.tick;
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
      widget.onError();
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
    return Center(
      child: SizedBox(
        width: 400,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            shape: getDefaultRoundedBorder(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  Text(
                    'Loading association data from the Mother Ship',
                    style: myTextStyleSmallBold(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
