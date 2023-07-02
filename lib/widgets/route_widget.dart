import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:badges/badges.dart' as bd;

class RouteWidget extends StatelessWidget {
  const RouteWidget({Key? key, required this.route}) : super(key: key);

  final lib.Route route;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: ListTile(
          title: Text('${route.name}'),
          subtitle: Text(
            '${route.associationName}',
            style: myTextStyleTiny(context),
          ),
          leading: Icon(
            Icons.water_damage,
            color: Theme.of(context).primaryColor,
          ),
        ));
  }
}

class RouteWidgetList extends StatelessWidget {
  const RouteWidgetList(
      {Key? key, required this.routes, required this.onRouteSelected})
      : super(key: key);
  final List<lib.Route> routes;
  final Function(lib.Route) onRouteSelected;

  @override
  Widget build(BuildContext context) {
    return bd.Badge(
      badgeContent: Text('${routes.length}'),
      position: bd.BadgePosition.topEnd(top: -16, end: 2),
      badgeStyle: bd.BadgeStyle(
          elevation: 12,
          padding: const EdgeInsets.all(12.0),
          badgeColor: Colors.teal[700]!),
      child: ListView.builder(
          itemCount: routes.length,
          itemBuilder: (ctx, index) {
            final rl = routes.elementAt(index);
            return GestureDetector(
                onTap: () {
                  onRouteSelected(rl);
                },
                child: RouteWidget(route: rl));
          }),
    );
  }
}
