import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../l10n/translation_handler.dart';
import '../data/data_schemas.dart' as lib;
import '../utils/functions.dart';
import '../utils/prefs.dart';

class CountryChooser extends StatefulWidget {
  const CountryChooser(
      {super.key,
      required this.onSelected,
      required this.hint,
      required this.refreshCountries});

  final Function(lib.Country) onSelected;
  final String hint;
  final bool refreshCountries;

  @override
  State<CountryChooser> createState() => CountryChooserState();
}

class CountryChooserState extends State<CountryChooser> {
  List<lib.Country> countries = <lib.Country>[];
  bool loading = false;
  lib.SettingsModel? settings;
  final mm = '😡 😡 😡 😡 CountryChooser 🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      loading = true;
    });
    settings = prefs.getSettings();
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
        list.add(DropdownMenuItem<lib.Country>(
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
        ? Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: Colors.pink,
                ),
              ),
          ],
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

class CountrySearch extends StatefulWidget {
  const CountrySearch({super.key, required this.onCountrySelected});

  final Function(lib.Country) onCountrySelected;

  @override
  State<CountrySearch> createState() => _CountrySearchState();
}

class _CountrySearchState extends State<CountrySearch>
    with AutomaticKeepAliveClientMixin {
  final mm = '🌀🌀🌀🌀CountrySearch: ';
  var _countries = <lib.Country>[];
  final _countriesToDisplay = <lib.Country>[];
  final _countryNames = <String>[];
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  void _runFilter(String text) {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      _countriesToDisplay.clear();
      for (var project in _countries) {
        _countriesToDisplay.add(project);
      }
      setState(() {});
      return;
    }
    _countriesToDisplay.clear();

    pp('$mm ...  filtering projects that contain: $text from ${_countryNames.length} countries');
    for (var name in _countryNames) {
      if (name.toLowerCase().contains(text.toLowerCase())) {
        var proj = _findCountry(name);
        if (proj != null) {
          _countriesToDisplay.add(proj);
        }
      }
    }
    pp('$mm .... set state with projectsToDisplay: ${_countriesToDisplay.length} ......');
    setState(() {});
  }

  lib.Country? _findCountry(String name) {
    pp('$mm ... find country by name $name from ${_countries.length}');
    for (var country in _countries) {
      if (country.name!.toLowerCase() == name.toLowerCase()) {
        return country;
      }
    }
    return null;
  }

  void _close(lib.Country country) {
    pp('$mm country selected: ${country.name}, popping out');
    widget.onCountrySelected(country);
    Navigator.of(context).pop(country);
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  bool busy = false;

  _getData() async {
    setState(() {
      busy = true;
    });
    _countries = await listApiDog.getCountries();
    _countries.sort((a, b) => a.name!.compareTo(b.name!));
    for (var p in _countries) {
      _countryNames.add(p.name!);
    }
    _countriesToDisplay.clear();
    for (var country in _countries) {
      _countriesToDisplay.add(country);
    }
    pp('$mm _countries: ${_countries.length}');

    pp('$mm _countriesToDisplay: ${_countriesToDisplay.length}');
    setState(() {
      busy = false;
    });
  }

  String? countriesText, search, searchCountries;
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var color2 = getTextColorForBackground(Theme.of(context).primaryColor);

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
      color2 = Colors.white;
    }

    return ScreenTypeLayout.builder(
      mobile: (ctx) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                countriesText == null ? 'Countries' : countriesText!,
                style: myTextStyleLargeWithColor(
                    context, Theme.of(context).primaryColor),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
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
                                          ? 'Search Countries'
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
                              child: Text('${_countriesToDisplay.length}',
                                  style: myTextStyleSmallWithColor(
                                      context, Colors.white)),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
              ],
            ),
            backgroundColor: isDarkMode
                ? Theme.of(context).dialogBackgroundColor
                : Colors.brown[50],
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                  itemCount: _countriesToDisplay.length,
                  itemBuilder: (ctx, index) {
                    var cntry = _countriesToDisplay.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        _close(cntry);
                      },
                      child: Card(
                        elevation: 2,
                        shape: getDefaultRoundedBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('${cntry.name}'),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
