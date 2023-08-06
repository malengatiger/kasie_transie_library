import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class PassengerCountCard extends StatelessWidget {
  const PassengerCountCard(
      {Key? key, required this.passengerCount, required this.backgroundColor})
      : super(key: key);

  final AmbassadorPassengerCount passengerCount;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 8,
      color: backgroundColor,
      child: SizedBox(
        height: 128,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Counter(title: 'In',
                      color: Colors.green,
                      fontSize: 20,
                      width: 60,
                      number: passengerCount.passengersIn!),
                  gapW12,
                  Counter(
                      color: Colors.red,
                      fontSize: 20,
                      width: 60,
                      title: 'Out', number: passengerCount.passengersOut!),
                  gapW12,
                  Counter(
                      title: 'Current',
                      color: Colors.white,
                      fontSize: 20,
                      width: 80,
                      number: passengerCount.currentPassengers!),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//
class Counter extends StatelessWidget {
  const Counter(
      {super.key,
      required this.title,
      required this.number,
      required this.width,
      required this.color,
      required this.fontSize});
  final String title;
  final int number;
  final double width;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: getRoundedBorder(radius: 8),
        color: Colors.black26,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 60,
            child: Column(
              children: [
                Text(title, style: myTextStyleSmall(context),),
                gapH8,
                Text(
                  '$number',
                  style:
                      myTextStyleMediumLargeWithColor(context, color, fontSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
