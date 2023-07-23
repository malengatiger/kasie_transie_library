import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

class RouteLandmarkWidget extends StatelessWidget {
  const RouteLandmarkWidget({Key? key, required this.routeLandmark}) : super(key: key);

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

class RouteLandmarkWidgetList extends StatelessWidget {
  const RouteLandmarkWidgetList({Key? key, required this.routeLandmarks, required this.onLandmarkSelected}) : super(key: key);
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

