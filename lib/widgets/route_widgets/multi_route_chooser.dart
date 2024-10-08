
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import '../../l10n/translation_handler.dart';

class MultiRouteChooser extends StatefulWidget {
  const MultiRouteChooser({super.key, required this.onRoutesPicked, required this.routes, required this.quitOnDone, required this.hideAppBar});

  final List<lib.Route> routes;
  final Function(List<lib.Route>) onRoutesPicked;
  final bool quitOnDone, hideAppBar;


  @override
  MultiRouteChooserState createState() => MultiRouteChooserState();
}

class MultiRouteChooserState extends State<MultiRouteChooser> {
  static const mm = '🔷🔷🔷 MultiRouteChooser';

  var list = <lib.Route>[];
  String selectRoutes = 'Select Routes';
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    super.initState();
    _control();
  }
  void _control() async {
    await _setTexts();
    _setCheckList();
    setState(() {

    });
  }
  void _setCheckList() {
    for (var element in widget.routes) {
      checkList.add(false);
    }
  }
  Future _setTexts() async {
    final c =  prefs.getColorAndLocale();
    final loc = c.locale;
    selectRoutes = await translator.translate('selectRoutes', loc);
    selectedRoutes = await translator.translate('selectedRoutes', loc);
    showRoutes = await translator.translate('show Routes', loc);
    setState(() {

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

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        leading: gapW16,
        title: widget.hideAppBar? gapW32: const Text('Route Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            gapH16,
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$selectedRoutes : ', style: myTextStyleMediumLargeWithColor(context,
                    Theme.of(context).primaryColorLight, 14),),
                SizedBox(
                  width: type == 'phone'?12:64,
                ),
                Text(
                  '${list.length}',
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 24),
                ),
                const SizedBox(
                  width: 24,
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            list.isEmpty
                ? gapH32
                : SizedBox(width: 300,
                  child: ElevatedButton(
                  onPressed: () {
                    widget.onRoutesPicked(list);
                    if (widget.quitOnDone) {
                      Navigator.of(context).pop(list);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(showRoutes),
                  )),
                ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: bd.Badge(
                badgeContent: Text('${widget.routes.length}'),
                position: bd.BadgePosition.topEnd(top: 8, end: -8),
                child: ListView.builder(
                    itemCount: widget.routes.length,
                    itemBuilder: (ctx, index) {
                      final route = widget.routes.elementAt(index);
                      final picked = checkList.isEmpty? false: checkList.elementAt(index);
                      return Card(
                        shape: getRoundedBorder(radius: 8),
                        elevation: 12,
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
    ));
  }
}


