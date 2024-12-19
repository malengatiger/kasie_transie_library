import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/maps/map_viewer.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/payment/commuter_cash_payment_widget.dart';
import 'package:kasie_transie_library/widgets/photo_handler.dart';
import 'package:kasie_transie_library/widgets/scanners/dispatch_helper.dart';

import 'ambassador/counter.dart';

class VehiclePassengerCount extends StatefulWidget {
  const VehiclePassengerCount(
      {super.key, required this.vehicle, required this.route});

  final lib.Vehicle vehicle;
  final lib.Route route;

  @override
  VehiclePassengerCountState createState() => VehiclePassengerCountState();
}

class VehiclePassengerCountState extends State<VehiclePassengerCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  static const mm = ' 🔷🔷🔷🔷🔷🔷 VehiclePassengerCount 🔷';
  var passengerCounts = <lib.AmbassadorPassengerCount>[];

  var currentCounts = <lib.AmbassadorPassengerCount>[];

  bool busy = false;
  bool showAllCounts = false;
  lib.User? user;
  String? passengersInText,
      passengerCounter,
      passengersOutText,
      currentPassengersText,
      passengerCountsaved,
      lastCount,
      errorCount,
      saveCounts;

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    passengersInText = await translator.translate('passengersIn', c.locale);
    passengersOutText = await translator.translate('passengersOut', c.locale);
    currentPassengersText =
        await translator.translate('currentPassengers', c.locale);
    saveCounts = await translator.translate('saveCounts', c.locale);
    passengerCounter = await translator.translate('passengerCount', c.locale);
    lastCount = await translator.translate('lastCount', c.locale);
    passengerCountsaved =
        await translator.translate('passengerCountsaved', c.locale);
    errorCount = await translator.translate('errorCount', c.locale);

    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _control();
  }

  void _control() async {
    user = prefs.getUser();
    await _setTexts();
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   _getVehiclePassengerCounts(false);
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getVehiclePassengerCounts(bool refresh) async {
    pp('$mm ... get prior VehiclePassengerCounts ...');
    try {
      setState(() {
        busy = true;
      });

      final startDate = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 8))
          .toIso8601String();
      passengerCounts = await listApiDog.getAmbassadorPassengerCountsByVehicle(
          vehicleId: widget.vehicle.vehicleId!,
          refresh: refresh,
          startDate: startDate);
      passengerCounts.sort((a, b) => b.created!.compareTo(a.created!));
      pp('$mm ... received prior VehiclePassengerCounts ...${E.appleRed} ${passengerCounts.length}');
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
      showAllCounts = true;
    });
  }

  String? lastDate;

  void _submitCounts() async {
    pp('$mm .. _submitCounts ...');
    setState(() {
      busy = true;
    });

    try {
      final loc = await locationBloc.getLocation();
      final passengerCount = lib.AmbassadorPassengerCount(
        associationId: user!.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        userId: user!.userId,
        vehicleId: widget.vehicle.vehicleId,
        vehicleReg: widget.vehicle.vehicleReg,
        userName: user!.name,
        currentPassengers: currentPassengers,
        passengersIn: passengersIn,
        passengersOut: passengersOut,
        ownerId: widget.vehicle.ownerId,
        ownerName: widget.vehicle.ownerName,
        position: lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.latitude,
        ),
        routeId: widget.route.routeId,
        routeName: widget.route.name,
      );

      pp('$mm sending counts: ${passengerCount.toJson()}');
      dataApiDog.addAmbassadorPassengerCount(passengerCount);
      pp('$mm .. _submitCounts seems OK!');
      var format = DateFormat.Hms();
      lastDate = format.format(DateTime.now());
      passengersOut = 0;
      passengersIn = 0;
      currentCounts.add(passengerCount);

      dispatchHelper.sendPassengerCount(passengerCount);
      if (mounted) {
        showOKToast(
            duration: const Duration(seconds: 2),
            padding: 20,
            message: passengerCountsaved == null
                ? 'Passenger Counts saved, thank you!'
                : passengerCountsaved!,
            context: context);
      }
      _navigateToCashPayment();
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
      showSubmit = false;
    });
  }

  void _navigateToCashPayment() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: CommuterCashPaymentWidget(
            vehicle: widget.vehicle, route: widget.route, onError: (err) {}));
  }

  void _navigateToPhotoHandler() {
    pp('$mm ... _navigateToPhotoHandler');

    NavigationUtils.navigateTo(
      context: context,
      widget: PhotoHandler(
          vehicle: widget.vehicle,
          onPhotoTaken: (file, thumb) {
            pp('$mm photo and thumbnail files returned from handler');
          }),
    );
  }

  int passengersIn = 0, passengersOut = 0, currentPassengers = 0;
  bool showSubmit = false;

  void _navigateToRouteMap() {
    pp('$mm ... _navigateToRouteMap');
    NavigationUtils.navigateTo(
        context: context, widget: MapViewer(route: widget.route));
  }

  _onPassengersIn(int number) {
    setState(() {
      currentPassengers = currentPassengers + number;
      passengersIn = number;
    });
  }

  _onPassengersOut(int number) {
    if (number > currentPassengers) {
      showErrorToast(
          message:
              'The number of passengers leaving the taxi should not be greater than the current passengers',
          context: context);
      return;
    }
    setState(() {
      currentPassengers = currentPassengers - number;
      passengersOut = number;
    });
  }

  _tripHasEnded() {
    pp('\n\n$mm ... _tripHasEnded ... room for a new data model? TripEnd anyone?');

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Text(
          passengerCounter == null ? 'Passengers' : passengerCounter!,
          style: myTextStyle(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToPhotoHandler();
              },
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              )),
          IconButton(
              onPressed: () {
                _navigateToRouteMap();
              },
              icon: Icon(Icons.map, color: Theme.of(context).primaryColor)),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${widget.vehicle.vehicleReg}',
                  style: myTextStyle(fontSize: 36, weight: FontWeight.w900),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${widget.route.name}',
                    style: myTextStyle(
                        fontSize: 16,
                        weight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                ),
                gapH16,
                PassengerCounter(
                    title: 'Passengers In',
                    count: 50,
                    fontSize: 36,
                    onNumberSelected: (number) {
                      _onPassengersIn(number);
                    },
                    color: Colors.blue),
                gapH16,
                PassengerCounter(
                    title: 'Passengers Out',
                    count: 50,
                    fontSize: 36,
                    onNumberSelected: (number) {
                      _onPassengersOut(number);
                    },
                    color: Colors.red),
                gapH32,
                Card(
                    elevation: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Current Passengers'),
                            gapW32,
                            Text(
                              '$currentPassengers',
                              style: myTextStyle(
                                  fontSize: 48,
                                  color: Colors.black,
                                  weight: FontWeight.w900),
                            )
                          ],
                        ))),
                gapH16,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                        elevation: WidgetStatePropertyAll(8)),
                    onPressed: () {
                      _submitCounts();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Submit',
                          style:
                              myTextStyle(color: Colors.white, fontSize: 24)),
                    ),
                  ),
                ),
                gapH32,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        elevation: WidgetStatePropertyAll(2)),
                    onPressed: () {
                      _tripHasEnded();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Trip has Ended',
                        style: myTextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          busy
              ? const Positioned(
                  child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.amber,
                    ),
                  ),
                ))
              : const SizedBox(),
        ],
      ),
    ));
  }
}
