import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/photo_handler.dart';
import 'package:kasie_transie_library/widgets/video_recorder.dart';

class VehicleMediaHandler extends StatefulWidget {
  const VehicleMediaHandler({Key? key, required this.vehicle})
      : super(key: key);

  final lib.Vehicle vehicle;

  @override
  VehicleMediaHandlerState createState() => VehicleMediaHandlerState();
}

class VehicleMediaHandlerState extends State<VehicleMediaHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const mm = ' 🔷🔷🔷🔷🔷🔷 VehicleMediaHandler 🔷';
  var vehiclePhotos = <lib.VehiclePhoto>[];
  final videoFiles = <File>[];

  final photoThumbFiles = <File>[];
  bool busy = false;
  bool showAllPhotos = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getVehiclePhotos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getVehiclePhotos() async {
    pp('$mm ... get prior photos ...');
    setState(() {
      busy = true;
    });
    vehiclePhotos =
        await listApiDog.getVehiclePhotos(widget.vehicle.vehicleId!, false);
    setState(() {
      busy = false;
    });
  }

  void _navigateToPhotoHandler() {
    navigateWithScale(
        PhotoHandler(
            vehicle: widget.vehicle,
            onPhotoTaken: (file, tFile) {
              pp('$mm photo files received ${tFile.path}');

              setState(() {
                photoThumbFiles.add(tFile);
              });
            }),
        context);
  }

  void _navigateToVideoRecorder() {
    navigateWithScale(
        VideoRecorder(
            vehicle: widget.vehicle,
            onVideoMade: (file, tFile) {
              pp('$mm video files received ${tFile.path}');
              setState(() {
                videoFiles.add(file);
                photoThumbFiles.add(tFile);
              });
            }),
        context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Media'),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              showAllPhotos = !showAllPhotos;
            });
          }, icon: const Icon(Icons.list)),
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
                  height: 12,
                ),
                Expanded(
                  child: showAllPhotos
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: vehiclePhotos.length,
                          itemBuilder: (ctx, index) {
                            final photo = vehiclePhotos.elementAt(index);
                            return Card(
                              elevation: 8,
                              shape: getRoundedBorder(radius: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(photo.thumbNailUrl!,
                                fit: BoxFit.cover,
                                ),
                              ),
                            );
                          })
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: photoThumbFiles.length,
                          itemBuilder: (ctx, index) {
                            var file = photoThumbFiles.elementAt(index);
                            return Card(
                              elevation: 8,
                              shape: getRoundedBorder(radius: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
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
                  onVideo: _navigateToVideoRecorder)),
        ],
      ),
    ));
  }
}

class MediaChooser extends StatelessWidget {
  const MediaChooser({Key? key, required this.onPhoto, required this.onVideo})
      : super(key: key);
  final Function onPhoto;
  final Function onVideo;

  @override
  Widget build(BuildContext context) {
    var type = -1;
    return SizedBox(
      height: 120,
      width: 300,
      child: Card(
        color: Colors.black26,
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Column(
          children: [
            RadioListTile(
              title: const Text("Take Photos"),
              value: 0,
              groupValue: type,
              onChanged: (value) {
                onPhoto();
              },
            ),
            RadioListTile(
              title: const Text("Make Videos"),
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
