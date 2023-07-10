import 'package:flutter/material.dart';

import '../utils/functions.dart';

class MediaChooser extends StatelessWidget {
  const MediaChooser(
      {Key? key,
        required this.onPhoto,
        required this.onVideo,
        required this.takePhotoText,
        required this.makeVideoText})
      : super(key: key);
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
        color: Colors.black26,
        shape: getRoundedBorder(radius: 16),
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