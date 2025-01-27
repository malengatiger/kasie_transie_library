import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';

import '../../bloc/list_api_dog.dart';
import '../../bloc/sem_cache.dart';
import '../../data/data_schemas.dart' as lib;
import '../../messaging/fcm_bloc.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';

class CarPassengerCounts extends StatefulWidget {
  const CarPassengerCounts(
      {super.key, required this.vehicle, this.startDate, this.endDate});

  final lib.Vehicle vehicle;
  final String? startDate, endDate;

  @override
  CarPassengerCountsState createState() => CarPassengerCountsState();
}

class CarPassengerCountsState extends State<CarPassengerCounts>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🍅🍅🍅🍅CarPassengerCounts 🍐🍅🍐';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  lib.VehicleData? vehicleData;

  // late StreamSubscription<lib.LocationResponse> respSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerCountStreamSub;
  late FCMService fcmService = GetIt.instance<FCMService>();
  SemCache semCache = GetIt.instance<SemCache>();
  int hours = 24;
  bool busy = false;
  String title = "Taxi Passengers";
  String? startDate, endDate;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getVehicleData();
  }

  List<DateCount> dateCounts = [];
  List<DateAmount> dateAmounts = [];
  List<DateSummary> dateSummaries = [];

  Future _getVehicleData() async {
    pp('$mm ... _getVehicleData that shows the last ${E.blueDot} $hours hours .... ');
    if (widget.startDate == null) {
      var now = DateTime.now().subtract(const Duration(hours: 24));
      startDate =
          DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    } else {
      var now = DateTime.parse(widget.startDate!);
      startDate =
          DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    }

    if (widget.endDate == null) {
      var end = DateTime.now();
      endDate =
          DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();
    } else {
      var end = DateTime.parse(widget.endDate!);
      endDate =
          DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();
    }

    final sd = DateTime.parse(startDate!).toUtc().toIso8601String();
    final ed = DateTime.parse(endDate!).toUtc().toIso8601String();

    setState(() {
      busy = true;
    });
    try {
      vehicleData = await listApiDog.getVehicleData(
          vehicleId: widget.vehicle.vehicleId!, startDate: sd, endDate: ed);
      if (mounted) {
        if (vehicleData != null) {
          _getDistinctDates(
              vehicleData!.passengerCounts, vehicleData!.commuterCashPayments);
        }
      }
    } catch (e, stack) {
      pp('$e - $stack');
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.red,
            message: 'Could not get data for you. Please try again',
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _getDistinctDates(List<lib.AmbassadorPassengerCount> passengerCounts,
      List<CommuterCashPayment> cashPayments) {
    Set<String> distinctCountDates = {};
    Set<String> distinctAmountDates = {}; // Use a Set to store unique dates
// Use a Set to store unique dates
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    dateCounts.clear();
    for (var count in passengerCounts) {
      try {
        DateTime createdDate = DateTime.parse(count.created!);
        String formattedDate = dateFormat.format(createdDate);
        distinctCountDates.add(formattedDate);
      } catch (e) {
        pp('Error parsing date: ${count.created} - $e');
      }
    }
    for (var date in distinctCountDates) {
      var total = 0;
      for (var count in passengerCounts) {
        DateTime createdDate = DateTime.parse(count.created!);
        String formattedDate = dateFormat.format(createdDate);
        if (formattedDate == date) {
          total += count.passengersIn!;
        }
      }
      dateCounts.add(DateCount(date, total));
    }

    dateSummaries.clear();
    for (var date in distinctCountDates) {
      dateSummaries.add(DateSummary(date: date, count: 0, amount: 0.00));
    }
    for (var ds in dateSummaries) {
      var total = 0.0;
      for (var payment in cashPayments) {
        DateTime createdDate = DateTime.parse(payment.created!);
        String formattedDate = dateFormat.format(createdDate);
        if (ds.date == formattedDate) {
          total += payment.amount!;
        }
      }
      pp('$mm commuter cashPayments: ${ds.date} -  $total ');
      ds.amount = total;
    }

    for (var dateSummary in dateSummaries) {
      var total = 0;
      for (var pCount in passengerCounts) {
        DateTime createdDate = DateTime.parse(pCount.created!);
        String formattedDate = dateFormat.format(createdDate);
        if (dateSummary.date == formattedDate) {
          total += pCount.passengersIn!!;
        }
      }
      pp('$mm  passengers: ${dateSummary.date} -  $total ');
      dateSummary.count = total;
    }

    for (var dc in dateSummaries) {
      pp('$mm Date Summary: ${dc.date} - 🎽${dc.count} - 🍑 ${dc.amount}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat nfAmount = NumberFormat('###,###,##0.00');
    NumberFormat nfCount = NumberFormat('###,###,###');
    var totalPassengers = 0;
    for (var count in vehicleData!.passengerCounts) {
      totalPassengers += count.passengersIn!;
    }
    var totalCash = 0.00;
    for (var count in vehicleData!.commuterCashPayments) {
      totalCash += count.amount!;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                gapH32,
                Text('${widget.vehicle.vehicleReg}', style: myTextStyleBold(fontSize: 36)),
                gapH32,
                startDate == null
                    ? gapW32
                    : PeriodWidget(
                        startDate: startDate!,
                        endDate: endDate!,
                      ),
                gapH4,
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                      itemCount: dateSummaries.length,
                      itemBuilder: (ctx, index) {
                        var summary = dateSummaries[index];
                        DateFormat dateFormat = DateFormat.MMMMd();
                        DateTime createdDate = DateTime.parse(summary.date!);
                        String formattedDate = dateFormat.format(createdDate);
                        return Card(
                            elevation: 8,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(formattedDate,
                                        style: myTextStyle(color: Colors.grey)),
                                  ),
                                  SizedBox(
                                    width: 64,
                                    child: Text(nfCount.format(summary.count!),
                                        style: myTextStyleBold(
                                            color: Colors.pink)),
                                  ),
                                  SizedBox(
                                    width: 48,
                                    child: Text('Cash',
                                        style: myTextStyle(color: Colors.grey)),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(nfAmount.format(summary.amount),
                                        style: myTextStyleBold(
                                            color: Colors.green.shade700)),
                                  )
                                ],
                              ),
                            ));
                      }),
                ))
              ],
            ),
            busy
                ? Positioned(
                    child: Center(
                        child: CircularProgressIndicator(
                    strokeWidth: 4,
                  )))
                : gapW32,
            dateSummaries.isNotEmpty
                ? Positioned(
                    bottom: 24, left: 8,
                    child: Card(
                        elevation: 16,
                        color: Colors.yellow.shade50,
                        child: Padding(
                          padding: EdgeInsets.all(16), child: SizedBox(height: 72, width: 300,
                            child: Column(
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                     SizedBox(width: 100,
                                       child: Text('Passengers', style: myTextStyleBold(color: Colors.grey, fontSize: 16)),),
                                    Text(nfCount.format(totalPassengers), style: myTextStyleBold(color: Colors.pink)),
                                  ],
                                ),
                          gapH4,
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 100,
                                child: Text('Total Cash', style: myTextStyleBold(color: Colors.grey, fontSize: 16)),),
                              Text(nfAmount.format(totalCash),
                                  style: myTextStyleBold(
                                      fontSize: 24,
                                      color: Colors.green.shade700)),
                                ],
                              ),
                              ],
                            ), )
                        )))
                : gapW32,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getVehicleData();
        },
        child: FaIcon(FontAwesomeIcons.arrowsRotate),
      ),
    );
  }
}

class DateCount {
  final String date;
  final int count;

  DateCount(this.date, this.count);
}

class DateAmount {
  final String date;
  final double amount;

  DateAmount(this.date, this.amount);
}

class DateSummary {
  String? date;
  int? count;
  double? amount;

  DateSummary({required this.date, required this.count, required this.amount});
}

class PeriodWidget extends StatelessWidget {
  const PeriodWidget(
      {super.key, required this.startDate, required this.endDate});

  final String startDate, endDate;

  @override
  Widget build(BuildContext context) {
    DateFormat df = DateFormat.MMMMEEEEd();
    NumberFormat nf = NumberFormat('###,###,##0.00');
    var start = df.format(DateTime.parse(startDate!));
    var end = df.format(DateTime.parse(endDate!));

    return Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 48,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Starting',
                        style: myTextStyle(
                            color: Colors.grey, weight: FontWeight.w900)),
                  ),
                  Text(start,
                      style: myTextStyle(
                          color: Colors.grey, weight: FontWeight.normal)),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Ending',
                      style: myTextStyle(
                          color: Colors.grey, weight: FontWeight.w900),
                    ),
                  ),
                  Text(end,
                      style: myTextStyle(
                          color: Colors.grey, weight: FontWeight.normal)),
                ],
              ),
            ],
          ),
        ));
  }
}
