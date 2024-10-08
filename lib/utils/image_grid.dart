import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key, required this.crossAxisCount});
  final int crossAxisCount;
  @override
  Widget build(BuildContext context) {
    final List<String> assetPaths = [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
      'assets/images/5.jpg',
      'assets/images/6.jpg',
      'assets/images/7.jpg',
      'assets/images/8.jpg',
      'assets/images/9.jpg',
      'assets/images/10.jpg',
    ];
    return Scaffold(
      body: Stack(
        children: [
          GridView.builder(
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount),
              itemCount: assetPaths.length,
              itemBuilder: (_, index) {
                var path = assetPaths[index];
                return Image.asset(path, fit: BoxFit.cover);
              }),
        ],
      ),
    );
  }


}
