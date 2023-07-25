import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import '../../l10n/translation_handler.dart';

class MultiRouteChooser extends StatefulWidget {
  const MultiRouteChooser({Key? key, required this.onRoutesPicked})
      : super(key: key);

  final Function(List<lib.Route>) onRoutesPicked;

  @override
  MultiRouteChooserState createState() => MultiRouteChooserState();
}

class MultiRouteChooserState extends State<MultiRouteChooser> {
  static const mm = '🔷🔷🔷 MultiRouteChooser';

  List<lib.Route> routes = [];
  var list = <lib.Route>[];
  String selectRoutes = 'Select Routes';

  bool busy = false;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _getRoutes();
  }

  void _setTexts() async {
    final c = await prefs.getColorAndLocale();
    final loc = c.locale;
    selectRoutes = await translator.translate('selectRoutes', loc);
    selectedRoutes = await translator.translate('selectedRoutes', loc);
    showRoutes = await translator.translate('show Routes', loc);
    setState(() {

    });
  }

  void _getRoutes() async {
    final user = await prefs.getUser();
    setState(() {
      busy = true;
    });
    try {
      routes = await listApiDog
          .getRoutes(AssociationParameter(user!.associationId!, false));
      for (var r in routes) {
        checkList.add(false);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  void _addRoute(lib.Route route) {
    pp('$mm ... _addRoute to list : route: ${route.name} ... list: ${list.length}');
    list.add(route);
    pp('$mm ... _addRoute to list : route: ${route.name} ... list: ${list.length}');

  }

  void _removeRoute(lib.Route route) {
    pp('$mm ... _removeRoute to list : route: ${route.name} ... list: ${list.length}');
    try {
      list.remove(route);
      pp('$mm ... _removeRoute to list : route: ${route.name} ... list: ${list.length}');

    } catch (e) {
      pp(e);
    }
  }

  var checkList = <bool>[];
  var selectedRoutes = 'selectedRoutes';
  var showRoutes = 'show Routes';

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    return SizedBox(height: type == 'phone'?480:640, width: type == 'phone'?400: 600,
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text('$selectedRoutes : ', style: myTextStyleMediumLargeWithColor(context,
                      Theme.of(context).primaryColorLight, 16),),
                   SizedBox(
                    width: type == 'phone'?24:64,
                  ),
                  Text(
                    '${list.length}',
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColorDark, 20),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  list.isEmpty
                      ? const SizedBox()
                      : ElevatedButton(
                          onPressed: () {
                            widget.onRoutesPicked(list);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(showRoutes),
                          )),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: bd.Badge(
                  badgeContent: Text('${routes.length}'),
                  position: bd.BadgePosition.topEnd(top: 8, end: -8),
                  child: ListView.builder(
                      itemCount: routes.length,
                      itemBuilder: (ctx, index) {
                        final route = routes.elementAt(index);
                        final picked = checkList.elementAt(index);
                        return Card(
                          shape: getRoundedBorder(radius: 16),
                          elevation: 8,
                          child: Row(
                            children: [
                              Checkbox(
                                  value: picked,
                                  onChanged: (checked) {
                                    pp('$mm ... Checkbox: checked: $checked ...');
                                    if (checked != null) {
                                      checkList[index] = checked;
                                      if (checked) {
                                        _addRoute(route);
                                      } else {
                                        _removeRoute(route);
                                      }
                                    }
                                    setState(() {});

                                  }),
                              const SizedBox(
                                width: 2,
                              ),
                              Flexible(
                                child: Text(
                                  '${route.name}',
                                  style: myTextStyleSmall(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
