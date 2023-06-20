import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'functions.dart';

final Initializer initializer = Initializer();
class Initializer {
  final mm = '😡😡😡😡😡😡😡 Initializer 😡 ';

  Future getCountries() async {
    pp('$mm ... getCountries starting ....');
    var list = await listApiDog.getCountries();
    pp('$mm ... initialization complete ... countries found: ${list.length}');
  }
}
