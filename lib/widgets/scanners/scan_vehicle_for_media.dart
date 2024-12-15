import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/widgets/vehicle_media_handler.dart';
import 'package:page_transition/page_transition.dart';

import '../../bloc/list_api_dog.dart';
import '../../utils/navigator_utils.dart';
import 'kasie/kasie_ai_scanner.dart';

class ScanVehicleForMedia extends StatefulWidget {
  const ScanVehicleForMedia({super.key});

  @override
  ScanVehicleForMediaState createState() => ScanVehicleForMediaState();
}

class ScanVehicleForMediaState extends State<ScanVehicleForMedia>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForMedia: 🍎🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  lib.Vehicle? vehicle;
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

  void navigateToMediaHandler() async {
    pp('$mm ... navigate to VehicleMediaHandler ... for car: ${vehicle!.vehicleReg}');

    NavigationUtils.navigateTo(context: context, widget: VehicleMediaHandler(vehicle: vehicle!,),
        );
  }

  void onCarScanned(lib.Vehicle car) async {
    vehicle = car;
    pp('$mm ... onCarScanned; scanner returned ${vehicle!.vehicleReg} ...');
    setState(() {
    });
    navigateToMediaHandler();
  }

  void onError() {}
  String? vehicleMedia, scanVehicle, scanTheVehicle, startPhotoVideo, noVehicleScanned;

  void _setTexts() async {
    pp('$mm ... _setTexts ...');
    final c = prefs.getColorAndLocale();
    vehicleMedia = await translator.translate('vehicleMedia', c.locale);
    scanVehicle = await translator.translate('scanVehicle', c.locale);
    scanTheVehicle = await translator.translate('scanTheVehicle', c.locale);
    startPhotoVideo = await translator.translate('startPhotoVideo', c.locale);
    noVehicleScanned = await translator.translate('noVehicleScanned', c.locale);
    pp('$mm ... _setTexts ... setting state, vehicleMedia: $vehicleMedia with locale: ${c.locale}');

    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(vehicleMedia == null?
            'Vehicle Media':vehicleMedia!),
        // bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(420),
        //     child: Column(
        //       children: [
        //         const SizedBox(
        //           height: 8,
        //         ),
        //         Text(scanVehicle == null?
        //           'Scan Vehicle':scanVehicle!,
        //           style: myTextStyleMediumLargeWithColor(
        //               context, Theme.of(context).primaryColor, 28),
        //         ),
        //         Text(scanTheVehicle == null?
        //           'Scan the vehicle that you want to work with': scanTheVehicle!,
        //           style: myTextStyleSmall(context),
        //         ),
        //         const SizedBox(
        //           height: 32,
        //         ),
        //         GestureDetector(
        //           onTap: (){
        //             pp('$mm .... will try to restart a scan ...');
        //           },
        //           child: KasieAIScanner(onScanned: (json ) {
        //             onCarScanned(lib.Vehicle.fromJson(json));
        //           },),
        //         ),
        //         const SizedBox(
        //           height: 8,
        //         ),
        //       ],
        //     )),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  vehicle == null? KasieAIScanner(onScanned: (json){
                    pp('$mm car scanned: $json');
                   onCarScanned(lib.Vehicle.fromJson(json));
                   
                  }) : gapW4,
                  gapH32,
                  vehicle != null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 48,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${vehicle!.vehicleReg}',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme.of(context).primaryColor, 40),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),

                      ElevatedButton(
                          style: const ButtonStyle(
                              elevation: WidgetStatePropertyAll(8.0)
                          ),
                          onPressed: () {
                            navigateToMediaHandler();
                          },
                          child:  Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(startPhotoVideo == null?
                            'Start Photo & Video Capture': startPhotoVideo!),
                          )),
                    ],
                  )
                      : Text(noVehicleScanned == null?
                  'No Vehicle Scanned yet':noVehicleScanned!,
                    style: myTextStyleMediumLargeWithColor(
                        context, Colors.grey.shade700, 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
