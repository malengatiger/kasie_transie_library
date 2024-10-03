import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';

class RouteLandmarkWidget extends StatelessWidget {
  const RouteLandmarkWidget({super.key, required this.routeLandmark});

  final lib.RouteLandmark routeLandmark;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 8,
      child: ListTile(
        title: Text('${routeLandmark.routeName}'),
        subtitle: Text('${routeLandmark.landmarkName}', style: myTextStyleTiny(context),),
        leading:  Icon(Icons.water_damage, color: Theme.of(context).primaryColor,),
      )
    );
  }
}

class RouteLandmarkWidgetList extends StatelessWidget  {
  const RouteLandmarkWidgetList({super.key, required this.routeLandmarks, required this.onLandmarkSelected});
  final List<lib.RouteLandmark> routeLandmarks;
  final Function(lib.RouteLandmark) onLandmarkSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: routeLandmarks.length,
        itemBuilder: (ctx, index){
          final rl = routeLandmarks.elementAt(index);
          return GestureDetector(
              onTap: (){
                onLandmarkSelected(rl);
              },
              child: RouteLandmarkWidget(routeLandmark: rl));
        });
  }
}

