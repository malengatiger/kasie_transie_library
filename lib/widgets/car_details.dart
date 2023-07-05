import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/counter_bag.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/number_widget.dart';

class CarDetails extends StatefulWidget {
  const CarDetails(
      {Key? key, required this.vehicle, this.width, required this.onClose})
      : super(key: key);

  final lib.Vehicle vehicle;
  final double? width;
  final Function onClose;

  @override
  CarDetailsState createState() => CarDetailsState();
}

class CarDetailsState extends State<CarDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🐦🐦🐦🐦🐦🐦🐦 CarDetails 🍎🍎';
  var counts = <CounterBag>[];
  int days = 30;
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  void _getData() async {
    pp('$mm ... getData ...');
    setState(() {
      busy = true;
    });
    try {
      final m = DateTime.now().toUtc().subtract(Duration(days: days));
      counts = await listApiDog.getVehicleCountsByDate(
          widget.vehicle.vehicleId!, m.toIso8601String());
      pp('$mm ... counts retrieved ...');
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }
 String? tapToClose, numberOfDays;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: widget.width == null ? bWidth : widget.width!,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Card(
              child: Column(
                children: [
                  const SizedBox(
                    height: 48,
                  ),
                  Text(
                    widget.vehicle.vehicleReg!,
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 28),
                  ),
                  Text(tapToClose == null?
                    'Tap anywhere to close': tapToClose!,
                    style: myTextStyleTiny(context),
                  ),
                  Row(
                    children: [
                       Text(numberOfDays == null?
                          'Number of Days': numberOfDays!),
                      const SizedBox(
                        width: 12,
                      ),
                      Text('$days'),
                      DropdownButton<int>(
                          items: const [
                            DropdownMenuItem<int>(value: 1, child: Text("1")),
                            DropdownMenuItem<int>(value: 2, child: Text("2")),
                            DropdownMenuItem<int>(value: 3, child: Text("3")),
                            DropdownMenuItem<int>(value: 4, child: Text("4")),
                            DropdownMenuItem<int>(value: 5, child: Text("5")),
                            DropdownMenuItem<int>(value: 6, child: Text("6")),
                            DropdownMenuItem<int>(value: 7, child: Text("7")),
                            DropdownMenuItem<int>(value: 14, child: Text("14")),
                            DropdownMenuItem<int>(value: 30, child: Text("30")),
                            DropdownMenuItem<int>(value: 60, child: Text("60")),
                            DropdownMenuItem<int>(value: 90, child: Text("90")),
                            DropdownMenuItem<int>(
                                value: 120, child: Text("120")),
                          ],
                          onChanged: (c) {
                            if (c != null) {
                              setState(() {
                                days = c;
                              });
                              _getData();
                            }
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  Expanded(
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              crossAxisCount: 2),
                      children: [
                        NumberWidget(
                            title: counts[0].description!,
                            number: counts[0].count!),
                        NumberWidget(
                            title: counts[1].description!,
                            number: counts[1].count!),
                        NumberWidget(
                            title: counts[2].description!,
                            number: counts[2].count!),
                        NumberWidget(
                            title: counts[3].description!,
                            number: counts[3].count!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          busy
              ? const Positioned(
                  left: 20,
                  right: 20,
                  top: 48,
                  bottom: 48,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }
}
