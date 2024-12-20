import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';

import '../../data/data_schemas.dart' as lib;
import '../../utils/functions.dart';
import '../../utils/prefs.dart';
import '../photo_handler.dart';
import '../vehicle_widgets/vehicle_search.dart';

class AssociationVehiclePhotoHandler extends StatefulWidget {
  const AssociationVehiclePhotoHandler({super.key});

  @override
  AssociationVehiclePhotoHandlerState createState() =>
      AssociationVehiclePhotoHandlerState();
}

class AssociationVehiclePhotoHandlerState
    extends State<AssociationVehiclePhotoHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  lib.Vehicle? vehicle;
  lib.User? user;
  List<File> imageFiles = [];
  List<File> thumbFiles = [];
  Prefs prefs = GetIt.instance<Prefs>();
  static const mm = '😎😎😎😎AssociationVehiclePhotoHandler 😎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _navigateToCarSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToCarSearch() async {
    await Future.delayed(const Duration(milliseconds: 100), () async {
      user = prefs.getUser();
      if (mounted) {
        pp('$mm go to car search .....');
        vehicle = await NavigationUtils.navigateTo(
            context: context,
            widget: VehicleSearch(
              associationId: user!.associationId!,
            ));
        imageFiles.clear();
        thumbFiles.clear();
        setState(() {});
      }
    });
  }

  _navigateToPhotoHandler() async {
    pp('$mm _navigateToPhotoHandler ...');
    NavigationUtils.navigateTo(
        context: context,
        widget: PhotoHandler(
          vehicle: vehicle!,
          onPhotoTaken: (imageFile, thumbFile) {
            pp('$mm .... photo taken: ${imageFile.path}');
            imageFiles.add(imageFile);
            thumbFiles.add(thumbFile);
            setState(() {});
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Photos',
          style: myTextStyle(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToCarSearch();
              },
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gapH32,
                vehicle == null
                    ? gapW32
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${vehicle?.vehicleReg}',
                              style: myTextStyle(
                                  fontSize: 36, weight: FontWeight.w900)),
                        ],
                      ),
                gapH32,
                imageFiles.isEmpty
                    ? Text('No photos yet',
                        style: myTextStyle(color: Colors.grey, fontSize: 24))
                    : Expanded(
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: imageFiles.length,
                            itemBuilder: (ctx, index) {
                              return Image.file(
                                imageFiles[index],
                                fit: BoxFit.cover,
                              );
                            }),
                      ),
                vehicle == null ? gapW32 : gapH8,
              ],
            ),
            vehicle == null
                ? gapW32
                : Positioned(
                    right: 8,
                    bottom: 8,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            elevation: WidgetStatePropertyAll(8),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.black26)),
                        onPressed: () {
                          _navigateToPhotoHandler();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Take Photo',
                            style:
                                myTextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
