import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;

import '../../bloc/list_api_dog.dart';
import 'kasie/kasie_ai_scanner.dart';


class ScanVehicleForInstall extends StatefulWidget {
  const ScanVehicleForInstall({super.key});

  @override
  ScanVehicleForInstallState createState() => ScanVehicleForInstallState();
}

class ScanVehicleForInstallState extends State<ScanVehicleForInstall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForInstall: 🍎🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

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

  void onCarScanned(lib.Vehicle car) async {
    pp('$mm ... onCarScanned; scanner returning : ${vehicle!.vehicleReg} ...');
    setState(() {
      vehicle = car;
    });
    Navigator.of(context).pop(car);
  }

  String? vehicleMedia,
      scanVehicle,
      scanTheVehicle,
      startPhotoVideo,
      updateCarOwnership = '',
      scanOwnerCar = 'scan the owner',
      noVehicleScanned;

  void onError() {}
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
          'Scan to Install',
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColorLight, 28),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: getDefaultRoundedBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      scanVehicle == null ? 'Scan Vehicle' : scanVehicle!,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColor, 28),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Scan the vehicle for initial installation',
                      style: myTextStyleSmall(context),
                    ),
                    const SizedBox(
                      height: 32,
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
                      height: 48,
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
            ),
          )
        ],
      ),
    ));
  }
}
