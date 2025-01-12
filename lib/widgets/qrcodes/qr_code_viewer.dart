import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class QrCodeViewer extends StatelessWidget {
  const QrCodeViewer({super.key, required this.qrCodeUrl});

  final String qrCodeUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Card(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CachedNetworkImage(
                  height: 400,
                  width: 400,
                  imageUrl: qrCodeUrl,
                ),
              )),
        )),
      ),
    );
  }
}
