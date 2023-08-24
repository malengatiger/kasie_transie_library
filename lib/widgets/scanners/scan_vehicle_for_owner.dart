import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/qr_scanner.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/widgets/vehicle_media_handler.dart';

import '../../utils/emojis.dart';

class ScanVehicleForOwner extends StatefulWidget {
  const ScanVehicleForOwner({Key? key}) : super(key: key);

  @override
  ScanVehicleForOwnerState createState() => ScanVehicleForOwnerState();
}

class ScanVehicleForOwnerState extends State<ScanVehicleForOwner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForOwner: 🍎🍎';

  lib.Vehicle? vehicle;
  bool busy = false;
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

  lib.Vehicle? updatedVehicle;

  void updateCar() async {
    pp('$mm ... updateCar on database ... for car: ${vehicle!.vehicleReg}');
    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      if (user != null && vehicle != null) {
        final updatedVehicle = lib.Vehicle(
          vehicle!.id,
          vehicleId: vehicle!.vehicleId,
          vehicleReg: vehicle!.vehicleReg,
          associationId: vehicle!.associationId,
          associationName: vehicle!.associationName,
          countryId: vehicle!.countryId,
          created: vehicle!.created,
          dateInstalled: vehicle!.dateInstalled,
          make: vehicle!.make,
          model: vehicle!.model,
          ownerId: user.userId,
          ownerName: user.name,
          passengerCapacity: vehicle!.passengerCapacity,
          qrCodeUrl: vehicle!.qrCodeUrl,
          year: vehicle!.year,
        );
        pp('$mm updated owner vehicle ${E.redDot}');
        myPrettyJsonPrint(updatedVehicle.toJson());
        vehicle = await dataApiDog.updateVehicle(updatedVehicle);
        listApiDog.getOwnerVehicles(user!.userId!, true);
        pp('$mm ... updatedCar ... vehicle: ${vehicle!.vehicleReg!}');
      }
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.green.shade700,
            message: 'Car updated OK', context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  void onCarScanned(lib.Vehicle car) async {
    pp('$mm ... onCarScanned; scanner returned ${vehicle!.vehicleReg} ...');
    setState(() {
      vehicle = car;
    });
  }

  void navigateToMedia() async {
    navigateWithSlide(VehicleMediaHandler(vehicle: vehicle!), context);
  }

  void onError() {}
  String? vehicleMedia,
      scanVehicle,
      scanTheVehicle,
      startPhotoVideo,
      updateCarOwnership = '',
      scanOwnerCar = 'scan the owner',
      noVehicleScanned;

  void _setTexts() async {
    pp('$mm ... _setTexts ...');
    final c = await prefs.getColorAndLocale();
    vehicleMedia = await translator.translate('vehicleMedia', c.locale);
    scanVehicle = await translator.translate('scanVehicle', c.locale);
    scanTheVehicle = await translator.translate('scanTheVehicle', c.locale);
    startPhotoVideo = await translator.translate('startPhotoVideo', c.locale);
    noVehicleScanned = await translator.translate('noVehicleScanned', c.locale);

    updateCarOwnership = await translator.translate('updateCarOner', c.locale);
    scanOwnerCar = await translator.translate('scanOwnerCar', c.locale);

    pp('$mm ... _setTexts ... setting state, vehicleMedia: $vehicleMedia with locale: ${c.locale}');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          vehicleMedia == null ? 'Vehicle Media' : vehicleMedia!,
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColorLight, 16),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(420),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  scanVehicle == null ? 'Scan Vehicle' : scanVehicle!,
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 28),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  scanOwnerCar == null
                      ? 'Scan the vehicle that you own and update the database'
                      : scanOwnerCar!,
                  style: myTextStyleSmall(context),
                ),
                const SizedBox(
                  height: 48,
                ),
                GestureDetector(
                  onTap: () {
                    pp('$mm .... will try to restart a scan ...');
                  },
                  child: QRScanner(
                    onCarScanned: (car) {
                      setState(() {
                        vehicle = car;
                      });
                      onCarScanned(car);
                    },
                    onUserScanned: (u) {},
                    onError: onError,
                    quitAfterScan: true,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            )),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  vehicle != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${vehicle!.vehicleReg}',
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      40),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4, backgroundColor: Colors.pink,
                                    ),
                                  )
                                : ElevatedButton(
                                    style: const ButtonStyle(
                                        elevation:
                                            MaterialStatePropertyAll(8.0)),
                                    onPressed: () {
                                      updateCar();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(updateCarOwnership == null
                                          ? 'Update Car Ownership'
                                          : updateCarOwnership!),
                                    )),
                            const SizedBox(
                              height: 24,
                            ),
                            ElevatedButton(
                                style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(8.0)),
                                onPressed: () {
                                  navigateToMedia();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(startPhotoVideo == null
                                      ? 'Photos and Videos'
                                      : startPhotoVideo!),
                                )),
                          ],
                        )
                      : Text(
                          noVehicleScanned == null
                              ? 'No Vehicle Scanned yet'
                              : noVehicleScanned!,
                          style: myTextStyleMediumLargeWithColor(
                              context, Colors.grey.shade700, 20),
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
