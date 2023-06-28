import 'package:kasie_transie_library/data/schemas.dart';

class CalculatedDistanceList {
  List<CalculatedDistance> calculatedDistances = [];

  CalculatedDistanceList(this.calculatedDistances);

  Map<String,dynamic> toJson() {
    List mList = [];
    for (var rp in calculatedDistances) {
      mList.add(rp.toJson());
    }

    Map<String, dynamic> map = {
      'calculatedDistances': mList,
    };
    return map;
  }
}
