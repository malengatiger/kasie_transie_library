import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/navigator_utils_old.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/photo_handler.dart';
import 'package:kasie_transie_library/widgets/vehicle_photo_widget.dart';
import 'package:kasie_transie_library/widgets/video_recorder.dart';
import 'package:badges/badges.dart' as bd;
import 'package:page_transition/page_transition.dart';

class VehicleMediaHandler extends StatefulWidget {
  const VehicleMediaHandler({super.key, required this.vehicle});

  final lib.Vehicle vehicle;

  @override
  VehicleMediaHandlerState createState() => VehicleMediaHandlerState();
}

class VehicleMediaHandlerState extends State<VehicleMediaHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  static const mm = ' 🔷🔷🔷🔷🔷🔷 VehicleMediaHandler 🔷';
  var vehiclePhotos = <lib.VehiclePhoto>[];
  final videoFiles = <File>[];

  final photoFiles = <File>[];
  bool busy = false;
  bool _showPriorPhotos = true;
  String? vehicleMedia,
      allPhotosVideos,
      photosAndVideosNow,
      takePhotos,
      makeVideos;
  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    vehicleMedia = await translator.translate('vehicleMedia', loc);
    allPhotosVideos = await translator.translate('allPhotosVideos', loc);
    takePhotos = await translator.translate('takePhotos', loc);
    makeVideos = await translator.translate('makeVideos', loc);
  }
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _controlSetup();
  }

  void _controlSetup() async {
    await _setTexts();
    setState(() {

    });
    Future.delayed(const Duration(milliseconds: 200), (){
      _getVehiclePhotos(false);
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getVehiclePhotos(bool refresh) async {
    pp('$mm ... get prior photos ...');
    try {
      setState(() {
        busy = true;
      });
      vehiclePhotos =
          await listApiDog.getVehiclePhotos(widget.vehicle, refresh);
      vehiclePhotos.sort((a, b) => b.created!.compareTo(a.created!));
      pp('$mm ... received prior photos ...${E.appleRed} ${vehiclePhotos.length}');
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
      _showPriorPhotos = true;
    });
  }

  Future<void> _navigateToPhotoHandler() async {
    await NavigationUtils.navigateTo(context: context, widget: PhotoHandler(
        vehicle: widget.vehicle,
        onPhotoTaken: (file, tFile) {
          pp('$mm photo files received ${file.path} ${tFile.path}');
          setState(() {
            photoFiles.insert(0, file);
          });
        }), transitionType: PageTransitionType.leftToRight);

    pp('$mm back from PhotoHandler ... set state ...');
    setState(() {
      _showPriorPhotos = false;
    });
  }

  void _navigateToVideoRecorder() {
    navigateWithScale(
        VideoRecorder(
            vehicle: widget.vehicle,
            onVideoMade: (file, tFile) {
              pp('$mm video files received ${tFile.path}');
              setState(() {
                videoFiles.add(file);
                photoFiles.add(tFile);
              });
            }),
        context);
  }

  void _navigateToDetail(lib.VehiclePhoto photo) {
    pp('$mm ... _navigateToDetail ............... ${E.redDot} Joe, do we get here?');

    // Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
    //   return VehiclePhotoWidget(vehiclePhoto: photo);
    // }));

    navigateWithScale(VehiclePhotoWidget(vehiclePhoto: photo), context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title:  Text(vehicleMedia == null?
        'Vehicle Media': vehicleMedia!),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _showPriorPhotos = !_showPriorPhotos;
                });
                if (_showPriorPhotos) {
                  _getVehiclePhotos(true);
                }
              },
              icon: const Icon(Icons.settings)),
          IconButton(
              onPressed: () {
                _getVehiclePhotos(true);
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          Card(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.vehicle.vehicleReg}',
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColor, 32),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                _showPriorPhotos
                    ? Text(
                        allPhotosVideos == null
                            ? 'All Vehicle Photos and Videos'
                            : allPhotosVideos!,
                        style: myTextStyleMediumBoldWithColor(
                            context: context,
                            color: Theme.of(context).primaryColor,
                            fontSize: 16),
                      )
                    : Text(
                        photosAndVideosNow == null
                            ? 'Photos and Videos taken now'
                            : photosAndVideosNow!,
                        style: myTextStyleMediumBoldWithColor(
                            context: context,
                            color: Colors.grey.shade700,
                            fontSize: 16),
                      ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: _showPriorPhotos
                      ? bd.Badge(
                          onTap: () {
                            pp('$mm badge tapped ... toggle?');
                            setState(() {
                              _showPriorPhotos = !_showPriorPhotos;
                            });
                          },
                          badgeContent: Text('${vehiclePhotos.length}'),
                          badgeStyle: bd.BadgeStyle(
                            badgeColor: Colors.blue.shade700,
                            padding: const EdgeInsets.all(12.0),
                          ),
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              itemCount: vehiclePhotos.length,
                              itemBuilder: (ctx, index) {
                                final photo = vehiclePhotos.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    pp('$mm photo from mongo tapped ... ${photo.vehicleReg} '
                                        '${E.pear}${E.pear} ${photo.created}?');
                                    _navigateToDetail(photo);
                                  },
                                  child: Card(
                                    elevation: 8,
                                    shape: getRoundedBorder(radius: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Image.network(
                                        photo.url!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      : bd.Badge(
                          onTap: () {
                            pp('$mm badge tapped ... show more ...?');
                            setState(() {
                              _showPriorPhotos = !_showPriorPhotos;
                            });
                          },
                          badgeContent: Text('${photoFiles.length}'),
                          badgeStyle: bd.BadgeStyle(
                            badgeColor: Colors.red.shade700,
                            padding: const EdgeInsets.all(12.0),
                          ),
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              itemCount: photoFiles.length,
                              itemBuilder: (ctx, index) {
                                var file = photoFiles.elementAt(index);
                                return GestureDetector(
                                  onTap: () async {
                                    final mod = await file.lastModified();
                                    pp('$mm current photo  tapped ... show date? $mod');
                                  },
                                  child: Card(
                                    elevation: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                )
              ],
            ),
          ),
          Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: MediaChooser(
                    onPhoto: _navigateToPhotoHandler,
                    onVideo: _navigateToVideoRecorder,
                    takePhotoText:
                        takePhotos == null ? 'Take Photos' : takePhotos!,
                    makeVideoText:
                        makeVideos == null ? 'Make Videos' : makeVideos!,
                  )),
          busy
              ? const Positioned(
                  child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.pink,
                    ),
                  ),
                ))
              : const SizedBox(),
        ],
      ),
    ));
  }
}

class MediaChooser extends StatelessWidget {
  const MediaChooser(
      {super.key,
      required this.onPhoto,
      required this.onVideo,
      required this.takePhotoText,
      required this.makeVideoText});
  final Function onPhoto;
  final Function onVideo;
  final String takePhotoText, makeVideoText;

  @override
  Widget build(BuildContext context) {
    var type = -1;
    return SizedBox(
      height: 120,
      width: 300,
      child: Card(
        color: Colors.black54,
        shape: getDefaultRoundedBorder(),
        elevation: 8,
        child: Column(
          children: [
            RadioListTile(
              title: Text(takePhotoText),
              value: 0,
              groupValue: type,
              onChanged: (value) {
                onPhoto();
              },
            ),
            RadioListTile(
              title: Text(makeVideoText),
              value: 1,
              groupValue: type,
              onChanged: (value) {
                onVideo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
