import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../l10n/translation_handler.dart';
import '../data/schemas.dart';
import '../utils/device_location_bloc.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

class CityChooser extends StatefulWidget {
  const CityChooser(
      {Key? key,
      required this.onSelected,
      required this.hint,
      required this.refreshCountries})
      : super(key: key);

  final Function(Country) onSelected;
  final String hint;
  final bool refreshCountries;

  @override
  State<CityChooser> createState() => CityChooserState();
}

class CityChooserState extends State<CityChooser> {
  List<Country> countries = <Country>[];
  bool loading = false;
  SettingsModel? settings;
  final mm = '😡 😡 😡 😡 CityChooser 🍎';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      loading = true;
    });
    settings = await prefs.getSettings();
    if (countries.isEmpty) {
      pp('$mm getting countries from realm ................');
      countries = await listApiDog.getCountries();
      pp('$mm ${countries.length} 🍎 countries found in realm');
    }
    countries.sort((a, b) => a.name!.compareTo(b.name!));
    await _buildDropDown();
    setState(() {
      loading = false;
    });
  }

  var list = <DropdownMenuItem>[];

  Future _buildDropDown() async {
    var style = myTextStyleSmall(context);
    for (var entry in countries) {
      var translated =
          await translator.translate('${entry.name}', settings!.locale!);
      var m = translated.replaceAll('UNAVAILABLE KEY:', '');
      if (mounted) {
        list.add(DropdownMenuItem<Country>(
          value: entry,
          child: Text(
            m,
            style: myTextStyleSmallWithColor(context, Colors.black),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.pink,
            ),
          )
        : DropdownButton(
            elevation: 4,
            hint: Text(
              widget.hint,
              style: myTextStyleSmall(context),
            ),
            items: list,
            onChanged: onChanged);
  }

  void onChanged(value) {
    widget.onSelected(value);
  }
}

class CitySearch extends StatefulWidget {
  const CitySearch({
    Key? key,
    required this.showScaffold,
    required this.onCitySelected,
    required this.cities,
    required this.title,
  }) : super(key: key);

  final bool showScaffold;
  final List<City> cities;
  final Function(City) onCitySelected;
  final String title;

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  final mm = '🌀🌀🌀🌀CitySearch: ';
  final _citiesToDisplay = <City>[];
  final _cityNames = <String>[];
  final _formKey = GlobalKey<FormState>();
  bool busy = false;
  User? user;

  String? countriesText, search, searchCountries;
  final _textEditingController = TextEditingController();

  void _runFilter(String text) {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      _citiesToDisplay.clear();
      for (var city in widget.cities) {
        _citiesToDisplay.add(city);
      }
      setState(() {});
      return;
    }
    _citiesToDisplay.clear();

    pp('$mm ...  filtering projects that contain: $text from ${_cityNames.length} countries');
    for (var name in _cityNames) {
      if (name.toLowerCase().contains(text.toLowerCase())) {
        var proj = _findCity(name);
        if (proj != null) {
          _citiesToDisplay.add(proj);
        }
      }
    }
    pp('$mm .... set state with projectsToDisplay: ${_citiesToDisplay.length} ......');
    setState(() {});
  }

  City? _findCity(String name) {
    pp('$mm ... find city by name $name from ${widget.cities.length}');
    for (var city in widget.cities) {
      if (city.name!.toLowerCase() == name.toLowerCase()) {
        return city;
      }
    }
    return null;
  }

  void _close(City city) {
    pp('$mm city selected: ${city.name}, widget.onCitySelected ...');
    widget.onCitySelected(city);
  }

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  void _setUp() {
    for (var p in widget.cities) {
      _cityNames.add(p.name!);
    }
    _citiesToDisplay.clear();
    for (var country in widget.cities) {
      _citiesToDisplay.add(country);
    }
    pp('$mm _cities: ${widget.cities.length}');

    pp('$mm _citiesToDisplay: ${_citiesToDisplay.length}');
  }

  @override
  Widget build(BuildContext context) {
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }

    if (widget.showScaffold) {
      Scaffold(
        appBar: AppBar(
          title: Text(
            countriesText == null ? 'Cities & Towns & Places' : countriesText!,
            style: myTextStyleMediumBoldWithColor(
                context, Theme.of(context).primaryColor),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(160),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 12.0),
                              child: TextField(
                                controller: _textEditingController,
                                onChanged: (text) {
                                  pp(' ........... changing to: $text');
                                  _runFilter(text);
                                },
                                decoration: InputDecoration(
                                    label: Text(
                                      search == null ? 'Search' : search!,
                                      style: myTextStyleSmall(
                                        context,
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.search,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                    hintText: searchCountries == null
                                        ? 'Search Cities'
                                        : searchCountries!,
                                    hintStyle: myTextStyleSmallWithColor(
                                        context, color)),
                              )),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        bd.Badge(
                          position: bd.BadgePosition.topEnd(),
                          badgeContent: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${_citiesToDisplay.length}',
                                style: myTextStyleSmallWithColor(
                                    context, Colors.white)),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Search Radius'),
                        const SizedBox(
                          width: 24,
                        ),
                        DropdownButton<int>(
                            hint: Text("Radius Control"),
                            items: const [
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10'),
                              ),
                              DropdownMenuItem(
                                value: 20,
                                child: Text('20'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30'),
                              ),
                              DropdownMenuItem(
                                value: 50,
                                child: Text('50'),
                              ),
                              DropdownMenuItem(
                                value: 100,
                                child: Text('10'),
                              ),
                              DropdownMenuItem(
                                value: 150,
                                child: Text('150'),
                              ),
                              DropdownMenuItem(
                                value: 200,
                                child: Text('200'),
                              ),
                              DropdownMenuItem(
                                value: 250,
                                child: Text('250'),
                              ),
                              DropdownMenuItem(
                                value: 300,
                                child: Text('300'),
                              ),
                              DropdownMenuItem(
                                value: 500,
                                child: Text('500'),
                              ),
                              DropdownMenuItem(
                                value: 600,
                                child: Text('600'),
                              ),
                            ],
                            onChanged: (i) {
                              pp('$mm drop down search radius: $i');
                              if (i == null) {
                                //_getData(i.toDouble());
                              } else {
                                //_getCurrentLocation(i.toDouble());
                              }
                            }),
                      ],
                    )
                  ],
                ),
              )),
          actions: [
            IconButton(
                onPressed: () {
                  //_getCurrentLocation(50.0);
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        backgroundColor: isDarkMode
            ? Theme.of(context).dialogBackgroundColor
            : Colors.brown[50],
        body: busy
            ? const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.purple,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                    itemCount: _citiesToDisplay.length,
                    itemBuilder: (ctx, index) {
                      var cntry = _citiesToDisplay.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          _close(cntry);
                        },
                        child: Card(
                          elevation: 2,
                          shape: getRoundedBorder(radius: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('${cntry.name}'),
                          ),
                        ),
                      );
                    }),
              ),
      );
    }

    return Card(
      shape: getRoundedBorder(radius: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bd.Badge(
          badgeContent: Text('${_citiesToDisplay.length}'),
          badgeStyle: const bd.BadgeStyle(padding: EdgeInsets.all(8.0)),
          child: Column(
            children: [
              Text(widget.title, style: myTextStyleMediumBoldPrimaryColor(context),),
              const SizedBox(
                height: 24,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _citiesToDisplay.length,
                    itemBuilder: (ctx, index) {
                      var cntry = _citiesToDisplay.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          _close(cntry);
                        },
                        child: Card(
                          elevation: 2,
                          shape: getRoundedBorder(radius: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('${cntry.name}'),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
