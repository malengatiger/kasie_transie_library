import 'dart:async';

import 'package:kasie_transie_library/data/data_schemas.dart';

class RouteUpdateListener {
  final StreamController<Route> _streamController = StreamController.broadcast();
  Stream<Route> get routeUpdateStream => _streamController.stream;

  void update(Route route) {
    _streamController.sink.add(route);
  }
}