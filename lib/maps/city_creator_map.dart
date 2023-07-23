import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';

import '../l10n/translation_handler.dart';
import '../widgets/searching_cities_busy.dart';

class CityCreatorMap extends ConsumerStatefulWidget {
  const CityCreatorMap({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => CityCreatorMapState();
}

class CityCreatorMapState extends ConsumerState<CityCreatorMap> {
  static const defaultZoom = 16.0;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition;
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  lib.User? _user;
  geo.Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  BitmapDescriptor? _dotMarker;

  final numberMarkers = <BitmapDescriptor>[];

  // List<BitmapDescriptor> _numberMarkers = [];
  final List<lib.RoutePoint> rpList = [];

  // List<lib.Landmark> _landmarks = [];
  List<lib.RoutePoint> existingRoutePoints = [];
  List<lib.Landmark> landmarksFromLocationSearch = [];

  List<poly.PointLatLng>? polylinePoints;

  int index = 0;
  bool sending = false;
  Timer? timer;
  int totalPoints = 0;
  lib.SettingsModel? settingsModel;
  int radius = 25;
  bool displayLandmark = false;

  var countryCities = <lib.City>[];
  var states = <lib.State>[];
  TextEditingController nameEditController = TextEditingController();
  LatLng? latLng;
  String? cityName;
  String searchingCities = 'searching';
  bool _showCityForm = false;

  lib.City? city; void _setTexts() async {
    final c = await prefs.getColorAndLocale();
    final loc = c.locale;
    searchingCities = await translator.translate('searchingCities', loc);
  }

  final mm = '🌀🌀🌀🌀🌀CityCreatorMap 🌀';

  @override
  void initState() {
    super.initState();
    _setTexts();
    _setup();

  }



  void _setup() async {
    setState(() {
      busy = true;
    });
    try {
      await _getStates();
      await _getSettings();
      await _getUser();
      await _getCurrentLocation();
      await _makeDotMarker();
      await _buildLandmarkIcons();
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }
  // 👌the hill is being climbed!
  lib.Country? country;
  Future _getStates() async {
    country = await prefs.getCountry();
    final m = ref.watch(statesProvider(country!.countryId!));
    if (m.hasValue) {
      states = m.value!;
      setState(() {});
    }
  }

  Future _getCurrentLocation() async {
    pp('$mm .......... get current location ....');
    _currentPosition = await locationBloc.getLocation();
    pp('$mm .......... get current location ....  🍎 found: ${_currentPosition!.toJson()}');
    _myCurrentCameraPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: defaultZoom,
    );
    setState(() {});
  }

  Future _getSettings() async {
    settingsModel = await prefs.getSettings();
    if (settingsModel != null) {
      radius = settingsModel!.vehicleGeoQueryRadius!;
      if (radius == 0) {
        radius = 40;
      }
    }
  }

  Future _buildLandmarkIcons() async {
    for (var i = 0; i < 10; i++) {
      var intList =
          await getBytesFromAsset("assets/numbers/number_${i + 1}.png", 84);
      numberMarkers.add(BitmapDescriptor.fromBytes(intList));
    }
    pp('$mm have built ${numberMarkers.length} markers for landmarks');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getUser() async {
    _user = await prefs.getUser();
  }

  Future _makeDotMarker() async {
    var intList = await getBytesFromAsset("assets/markers/footprint.png", 40);
    _dotMarker = BitmapDescriptor.fromBytes(intList);
    pp('$mm custom marker 💜 assets/markers/dot2.png created');
  }

  Future<void> _zoomToCity(City city) async {
    final latLng = LatLng(
        city.position!.coordinates.last, city.position!.coordinates.first);
    var cameraPos = CameraPosition(target: latLng, zoom: 13.0);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
    setState(() {});
  }

  lib.State? state;
  void _onMapTapped(LatLng latLng) {
    setState(() {
      this.latLng = latLng;
      _showCityForm = true;
    });
  }

  void _addNewCity() async {
    pp('$mm ... adding new city marker: $cityName ');

    _markers.add(Marker(
        markerId: MarkerId(DateTime.now().toIso8601String()),
        icon: _dotMarker!,
        onTap: () {
          pp('$mm .............. marker tapped: $index');
          //_deleteRoutePoint(routePoint);
        },
        infoWindow: InfoWindow(
            snippet: 'This is a new place',
            title: '🔵 $cityName',
            onTap: () {
              pp('$mm ............. infoWindow tapped, point index: $index');
              //_deleteLandmark(landmark);
            }),
        position: latLng!));

    setState(() {});

    var cameraPos = CameraPosition(target: latLng!, zoom: defaultZoom);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
    _addCityToDatabase();
  }
  void _addCityToDatabase() async {

    setState(() {
      busy = true;
    });
    try {
      var cities = await listApiDog.findCitiesByLocation(LocationFinderParameter(
          latitude: latLng!.latitude, limit: 2, longitude: latLng!.longitude, radiusInKM: 50));
      String? stateId;
      String? stateName;
      if (cities.isNotEmpty) {
        stateId = cities.first.stateId;
        stateName = cities.first.stateName;
      }
      final city = City(
          ObjectId(),
          cityId: Uuid.v4().toString(),
          name: cityName,
          countryId: country!.countryId,
          countryName: country!.name,
          stateName: stateName,
          stateId: stateId,
          position: lib.Position(
            type: point,
            coordinates: [latLng!.longitude, latLng!.latitude],
            latitude: latLng!.latitude,
            longitude: latLng!.longitude,
          )
      );
      pp('$mm adding city to the database now!! ${city.name}');
      var mCity = await dataApiDog.addCity(city);
      pp('$mm city should be in the database now!! ${mCity.name}');
    } catch (e) {
      pp('$mm ... error adding city : $e');
    }
    setState(() {
      busy = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Place Maker',
            style: myTextStyleLarge(context),
          ),
        ),
        key: _key,
        body: _currentPosition == null
            ? SearchingCitiesBusy(searchingCities: searchingCities,)
            : Stack(children: [
                GoogleMap(
                  mapType: isHybrid ? MapType.hybrid : MapType.normal,
                  myLocationEnabled: true,
                  markers: _markers,
                  circles: _circles,
                  polylines: _polyLines,
                  onTap: (latLng) {
                    _onMapTapped(latLng);
                  },
                  initialCameraPosition: _myCurrentCameraPosition!,
                  onMapCreated: (GoogleMapController controller) async {
                    _mapController.complete(controller);
                  },
                ),
                Positioned(
                    right: 12,
                    top: 28,
                    child: Container(
                      color: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                isHybrid = !isHybrid;
                              });
                            },
                            icon: Icon(
                              Icons.album_outlined,
                              color: isHybrid ? Colors.yellow : Colors.white,
                            )),
                      ),
                    )),
                Positioned(
                    left: 12,
                    top: 20,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Card(
                          color: Colors.black38,
                          shape: getDefaultRoundedBorder(),
                          elevation: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: 108,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Place Maker',
                                          style:
                                              myTextStyleMediumLarge(context, 20),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_back_ios,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          _user!.name,
                                          style: myTextStyleMediumWithColor(
                                            context,
                                            Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))),
                _showCityForm
                    ? Positioned(
                        bottom: 80,
                        left: 20,
                        right: 20,
                        child: SizedBox(
                          height: 360,
                          width: 400,
                          child: Card(
                            shape: getDefaultRoundedBorder(),
                            color: Colors.black54,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showCityForm = false;
                                            });
                                          },
                                          icon: const Icon(Icons.close,
                                              color: Colors.white))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'New Place',
                                    style: myTextStyleMediumLarge(context, 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: nameEditController,
                                    decoration: InputDecoration(
                                      label: const Text('Place Name'),
                                      labelStyle: myTextStyleSmall(context),
                                      hintText: 'Enter the name of the place',
                                      icon: const Icon(
                                          Icons.water_damage_outlined),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 48,
                                  ),

                                  ElevatedButton(
                                      onPressed: () {
                                        if (nameEditController
                                            .value.text.isEmpty) {
                                          showSnackBar(
                                              message: 'Please enter the name',
                                              context: context,
                                              padding: 16);
                                        } else {
                                          setState(() {
                                            _showCityForm = false;
                                          });
                                          cityName =
                                              nameEditController.value.text;
                                          _addNewCity();
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 28.0,
                                            right: 28,
                                            top: 16,
                                            bottom: 16),
                                        child: Text('Save Place'),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ))
                    : const SizedBox(),
                busy
                    ? const Positioned(
                        left: 300,
                        top: 300,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 12,
                            backgroundColor: Colors.purple,
                          ),
                        ))
                    : const SizedBox(),
              ]));
  }
}
