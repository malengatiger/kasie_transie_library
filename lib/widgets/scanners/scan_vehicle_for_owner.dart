import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils_old.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/widgets/vehicle_media_handler.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/emojis.dart';
import 'kasie/kasie_ai_scanner.dart';

class ScanVehicleForOwner extends StatefulWidget {
  const ScanVehicleForOwner({super.key});

  @override
  ScanVehicleForOwnerState createState() => ScanVehicleForOwnerState();
}

class ScanVehicleForOwnerState extends State<ScanVehicleForOwner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForOwner: 🍎🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  lib.Vehicle? vehicle;
  bool busy = false;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  lib.Vehicle? updatedVehicle;

  void _getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
    ].request();
    pp('$mm PermissionStatus: statuses: $statuses');
    if (await Permission.camera.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      await openAppSettings();
      return;
    }
    final ok = await Permission.camera.request().isGranted;
    if (!ok) {
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 15),
            message: 'Camera permission is required', context: context);
      }
    }
  }

  void updateCar() async {
    pp('$mm ... updateCar on database ... for car: ${vehicle!.vehicleReg}');
    setState(() {
      busy = true;
    });
    try {
      final user = prefs.getUser();
      if (user != null && vehicle != null) {
        final updatedVehicle = lib.Vehicle(
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
          year: vehicle!.year, fcmToken: '',
        );
        pp('$mm updated owner vehicle ${E.redDot}');
        myPrettyJsonPrint(updatedVehicle.toJson());
        var num = await dataApiDog.updateVehicle(updatedVehicle);
        listApiDog.getOwnerVehicles(user.userId!, true);
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
    final c = prefs.getColorAndLocale();
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
                  child: KasieAIScanner(onScanned: (json ) {
                    onCarScanned(lib.Vehicle.fromJson(json));
                  },),
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
                                            WidgetStatePropertyAll(8.0)),
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
                                    elevation: WidgetStatePropertyAll(8.0)),
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
                      : Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              noVehicleScanned == null
                                  ? 'No Vehicle Scanned yet'
                                  : noVehicleScanned!,
                              style: myTextStyleMediumLargeWithColor(
                                  context, Colors.grey.shade700, 20),
                            ),
                        ],
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
