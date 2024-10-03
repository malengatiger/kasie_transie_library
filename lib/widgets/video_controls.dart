import 'package:flutter/material.dart';

import '../utils/functions.dart';


class VideoControls extends StatelessWidget {
  const VideoControls(
      {super.key,
        required this.onRecord,
        required this.onPlay,
        required this.onPause,
        required this.onStop,
        required this.isPlaying,
        required this.isPaused,
        required this.isStopped,
        required this.isRecording,
        required this.onClose});
  final Function onPlay;
  final Function onPause;
  final Function onStop;
  final Function onRecord;
  final Function onClose;
  final bool isPlaying;
  final bool isPaused;
  final bool isStopped;
  final bool isRecording;
  @override
  Widget build(BuildContext context) {

    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 8,
      color: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: _onRecordTapped,
                icon: Icon(Icons.videocam, size: 40,
                    color: Theme.of(context).primaryColor)),

            IconButton(
                onPressed: _onPlayPaused,
                icon: Icon(Icons.pause, size: 40,color: Theme.of(context).primaryColor)),

            IconButton(
                onPressed: _onPlayStopped,
                icon: Icon(
                  Icons.stop, size: 40,
                  color: Theme.of(context).primaryColor,
                )),

          ],
        ),
      ),
    );
  }

  void _onRecordTapped() {
    onRecord();
  }

  void _onPlayTapped() {
    onPlay();
  }

  void _onPlayStopped() {
    pp('Video controls, onStop');
    onStop();
  }

  void _onPlayPaused() {
    onPause();
  }
}
