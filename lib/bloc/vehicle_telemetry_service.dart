import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';

import 'list_api_dog.dart';

class VehicleTelemetryService {

  late Timer timer;

  Future sendTelemetry(VehicleTelemetry telemetry) async {
    DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  }

  Future<List<VehicleTelemetry>> getTelemetry(String vehicleId, int minutes) async {
    ListApiDog dataApiDog = GetIt.instance<ListApiDog>();
    List<VehicleTelemetry> metrics = [];


    return metrics;
  }
}
