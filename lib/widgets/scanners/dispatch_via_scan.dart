import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/drop_down_widgets.dart';
import 'package:kasie_transie_library/widgets/passenger_count.dart';

import '../../bloc/data_api_dog.dart';
import '../../isolates/local_finder.dart';
import 'dispatch_helper.dart';
import 'kasie/kasie_ai_scanner.dart';

class DispatchViaScan extends StatefulWidget {
  const DispatchViaScan(
      {super.key, required this.route, required this.onDispatched});

  final lib.Route route;
  final Function(lib.DispatchRecord) onDispatched;

  @override
  DispatchViaScanState createState() => DispatchViaScanState();
}

class DispatchViaScanState extends State<DispatchViaScan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  final mm = '${E.heartOrange}${E.heartOrange}${E.heartOrange}${E.heartOrange}'
      ' ScanDispatch: ${E.heartOrange}${E.heartOrange} ';
  DataApiDog _dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  String? dispatchText,
      selectRouteText,
      scannerWaiting,
      cancelText,
      working,
      dispatchTaxi,
      confirmDispatch,
      no,
      yes,
      dispatchFailed,
      allPhotosVideos;
  lib.Vehicle? scannedVehicle;
  bool quitAfterScan = false;
  lib.User? user;

  bool busy = false;

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    dispatchText = await translator.translate('dispatch', loc);
    selectRouteText = await translator.translate('pleaseSelectRoute', loc);
    scannerWaiting = await translator.translate('scannerWaiting', loc);
    cancelText = await translator.translate('cancel', loc);
    working = await translator.translate('working', loc);
    confirmDispatch = await translator.translate('confirmDispatch', loc);
    no = await translator.translate('no', loc);
    yes = await translator.translate('yes', loc);
    dispatchTaxi = await translator.translate('dispatchTaxi', loc);

    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<lib.RouteLandmark?> findNearestLandmark(Position loc) async {
    final m = await localFinder.findNearestRouteLandmark(
        latitude: loc.latitude, longitude: loc.longitude, radiusInMetres: 200);
    if (m != null) {
      pp('$mm ... findNearestLandmark found: ${m.landmarkName} ${E.pear}  route: ${m.routeName}');
    }
    return m;
  }

  int passengerCount = 0;

  Future<void> _sendTheDispatchRecord() async {
    pp('$mm ... _sendTheDispatchRecord ...');
    late lib.DispatchRecord dispatchRecord;
    try {
      setState(() {
        busy = true;
      });
      user = prefs.getUser();
      final loc = await locationBloc.getLocation();
      pp('$mm ... _sendTheDispatchRecord ... ${loc.latitude} ${loc.longitude}');

      lib.RouteLandmark? mark = await findNearestLandmark(loc);
      dispatchRecord = lib.DispatchRecord(
          dispatchRecordId: DateTime.now().toIso8601String(),
          routeName: widget.route.name,
          routeId: widget.route.routeId,
          created: DateTime.now().toUtc().toIso8601String(),
          vehicleId: scannedVehicle!.vehicleId,
          vehicleReg: scannedVehicle!.vehicleReg,
          associationId: scannedVehicle!.associationId,
          ownerId: scannedVehicle!.ownerId,
          marshalId: user!.userId,
          marshalName: user!.name,
          dispatched: true,
          passengers: passengerCount,
          associationName: scannedVehicle!.associationName,
          position: lib.Position(
            type: 'Point',
            coordinates: [loc.longitude, loc.latitude],
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
          landmarkName: mark?.landmarkName,
          routeLandmarkId: mark?.landmarkId);
      //
      _dataApiDog.addDispatchRecord(dispatchRecord);
      pp('$mm ... _sendTheDispatchRecord ... sent ..... ${dispatchRecord.toJson()}');

      dispatchHelper.putDispatchOnStream(dispatchRecord);
      widget.onDispatched(dispatchRecord);

      if (mounted) {
        showToast(
            padding: 24,
            backgroundColor: Colors.green.shade900,
            duration: const Duration(seconds: 5),
            textStyle: const TextStyle(color: Colors.white),
            message: '${scannedVehicle!.vehicleReg} - Dispatch sent OK with $passengerCount passengers',
            context: context);
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      pp('$e $s');
    }
    setState(() {
      busy = false;
    });
  }

  bool showScanner = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          dispatchText == null ? 'Dispatch' : dispatchText!,
          style: myTextStyleMedium(context),
        ),
      ),
      body: SizedBox(
        width: width,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                elevation: 4,
                child: Column(
                  children: [
                    Text(
                      '${widget.route.name}',
                      style: myTextStyleMediumLarge(context, 24),
                    ),
                    gapH32,
                    scannedVehicle == null
                        ? const Text('Vehicle Not Scanned Yet')
                        : Text(
                            '${scannedVehicle!.vehicleReg}',
                            style: myTextStyleMediumLargeWithColor(
                                context, Colors.yellow, 32),
                          ),
                    Expanded(
                      child: KasieAIScanner(
                        onScanned: (json) {
                          setState(() {
                            scannedVehicle = lib.Vehicle.fromJson(json);
                          });
                        },
                      ),
                    ),
                    scannedVehicle == null? gapW4: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       const Text('Passengers'),
                       NumberDropDown(onNumberPicked: (number){
                         setState(() {
                           passengerCount = number;
                         });
                       }, color: Colors.black, count: 24, fontSize: 20),
                       Text('$passengerCount', style: myTextStyle(color: Colors.yellow, fontSize: 24, weight: FontWeight.w900)),
                     ],
                   ),
                    gapH32,
                    scannedVehicle == null
                        ? gapW4
                        : ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue),
                                elevation: WidgetStatePropertyAll(8.0)),
                            onPressed: () {
                              _sendTheDispatchRecord();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                dispatchTaxi == null
                                    ? 'Dispatch Taxi'
                                    : dispatchTaxi!,
                                style: myTextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    weight: FontWeight.w900),
                              ),
                            ),
                          ),
                    gapH32,
                  ],
                ),
              ),
            ),
            busy
                ? const Positioned(
                    child: Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator())))
                : gapH32,
          ],
        ),
      ),
    ));
  }
}

class DispatchGrid extends StatelessWidget {
  const DispatchGrid(
      {super.key, required this.dispatches, required this.title});

  final String title;
  final List<lib.DispatchRecord> dispatches;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 1, crossAxisSpacing: 1),
        itemCount: dispatches.length,
        itemBuilder: (ctx, index) {
          final car = dispatches.elementAt(index);
          return DispatchCarPlate(dispatchRecord: car);
        });
  }
}

//
class DispatchCarPlate extends StatelessWidget {
  const DispatchCarPlate({super.key, required this.dispatchRecord});

  final lib.DispatchRecord dispatchRecord;

  @override
  Widget build(BuildContext context) {
    var color = Colors.red.shade700;
    if (dispatchRecord.passengers! < 6) {
      color = Colors.amber.shade900;
    }
    if (dispatchRecord.passengers! >= 6) {
      color = Colors.teal.shade700;
    }
    if (dispatchRecord.passengers! > 16) {
      color = Colors.pink.shade700;
    }
    if (dispatchRecord.passengers! == 0) {
      color = Colors.grey;
    }
    final fmt = DateFormat('HH:mm:ss');
    final date = fmt.format(DateTime.parse(dispatchRecord.created!));
    return SizedBox(
      height: 80,
      width: 80,
      child: bd.Badge(
        badgeContent: Text(
          '${dispatchRecord.passengers}',
          style: myTextStyleSmall(context),
        ),
        position: bd.BadgePosition.topEnd(top: 2, end: -2),
        badgeStyle: bd.BadgeStyle(
          badgeColor: color,
          elevation: 8,
          padding: const EdgeInsets.all(6),
        ),
        child: Card(
          shape: getRoundedBorder(radius: 8),
          elevation: 8,
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                Text(
                  '${dispatchRecord.vehicleReg}',
                  style: myTextStyleMediumLarge(context, 16),
                ),
                Text(date, style: myTextStyleSmall(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
