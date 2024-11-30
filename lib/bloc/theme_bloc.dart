import 'dart:async';
import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';


class KasieThemeManager {
  final mm = '🍎🍎🍎KasieThemeManager 🍎🍎🍎: ';
  final Prefs prefs;

  KasieThemeManager(this.prefs) {
    pp('$mm ... ThemeBloc initializing ....');
    _initialize();
  }

  final StreamController<ColorAndLocale> themeStreamController =
      StreamController.broadcast();

  Stream<ColorAndLocale> get localeAndThemeStream =>
      themeStreamController.stream;

  ColorAndLocale? colorAndLocale;

  _initialize() async {
    colorAndLocale = prefs.getColorAndLocale();
    colorAndLocale ??= ColorAndLocale(themeIndex: 0, locale: 'en');
    pp('\n$mm initialize: theme index: ${colorAndLocale!.themeIndex}');
    pp('$mm initialize: locale = ${colorAndLocale!.locale} ... '
        'themeIndex: ${colorAndLocale!.themeIndex} in the stream');
    themeStreamController.sink.add(colorAndLocale!);
    pp('\n$mm initialize: things should be done - settings sent to themeStreamController');
  }

  ThemeBag getTheme(int index) {
    return SchemeUtil.getTheme(themeIndex: index);
  }

  Future<void> changeColorAndLocale(ColorAndLocale colorAndLocale) async {
    pp('\n\n$mm changing to theme index: ${colorAndLocale.themeIndex} ${colorAndLocale.locale}, adding to stream');
    themeStreamController.sink.add(colorAndLocale);

    pp('$mm changeToTheme has put a colorAndLocale on the themeStreamController');
  }

  int getThemeCount() {
    return SchemeUtil.getThemeCount();
  }

  closeStream() {
    themeStreamController.close();
  }
}

class SchemeUtil {
  static final List<ThemeBag> _themeBags = [];
  static final _rand = Random(DateTime.now().millisecondsSinceEpoch);
  static int index = 0;
  static const mm = '💚ThemeBloc 💚💚💚💚💚';

  static int getThemeCount() {
    _setThemes();
    return _themeBags.length;
  }

  static ThemeBag getTheme({required int themeIndex}) {
    if (_themeBags.isEmpty) {
      _setThemes();
    }
    if (themeIndex >= _themeBags.length) {
      return _themeBags.first;
    }

    final bag = _themeBags.elementAt(themeIndex);
    return bag;
  }

  static List<ColorFromTheme> getDarkThemeColors() {
    final colors = <ColorFromTheme>[];
    var index = 0;
    for (var value in _themeBags) {
      colors.add(ColorFromTheme(value.darkTheme.primaryColor, index));
      index++;
    }
    return colors;
  }

  static List<ColorFromTheme> getLightThemeColors() {
    final colors = <ColorFromTheme>[];
    var index = 0;
    for (var value in _themeBags) {
      colors.add(ColorFromTheme(value.lightTheme.primaryColor, index));
      index++;
    }
    return colors;
  }

  static ColorFromTheme getColorFromTheme(ColorAndLocale colorAndLocale) {
    var bag = getThemeByIndex(colorAndLocale.themeIndex);
    final cft =
        ColorFromTheme(bag.darkTheme.primaryColor, colorAndLocale.themeIndex);
    return cft;
  }

  static ThemeBag getRandomTheme() {
    if (_themeBags.isEmpty) _setThemes();
    var index = _rand.nextInt(_themeBags.length - 1);
    return _themeBags.elementAt(index);
  }

  static ThemeBag getThemeByIndex(int index) {
    if (_themeBags.isEmpty) _setThemes();
    if (index >= _themeBags.length || index < 0) index = 0;
    return _themeBags.elementAt(index);
  }

  static void _setThemes() {
    _themeBags.clear();
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.deepBlue, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.deepBlue, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.green, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.green, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.redWine, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.redWine, useMaterial3: true, background: Colors.grey.shade700)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.barossa, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.barossa, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mallardGreen, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mallardGreen, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mandyRed, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.red, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.red, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.blue, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.blue, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mango, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mango, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.indigo, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.indigo, useMaterial3: true, background: Colors.grey.shade700)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.hippieBlue, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.hippieBlue, useMaterial3: true, background: Colors.grey.shade700)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.deepPurple, useMaterial3: true, background: Colors.grey.shade700, colorScheme: ColorScheme.fromSwatch(backgroundColor: Colors.deepPurple)),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.deepPurple, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.espresso, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.espresso, useMaterial3: true, background: Colors.grey.shade700)));


    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.bigStone, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.bigStone, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.damask, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.damask, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.purpleBrown, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.purpleBrown, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.wasabi, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.wasabi, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.rosewood, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.rosewood, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.sanJuanBlue, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.sanJuanBlue, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.amber, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.amber, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.dellGenoa, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.dellGenoa, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.gold, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.gold, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.blueWhale, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.ebonyClay, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.money, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.money, useMaterial3: true, background: Colors.grey.shade700)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.aquaBlue, useMaterial3: true, background: Colors.grey.shade700),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue, useMaterial3: true, background: Colors.grey.shade700)));

  }
}

class ColorFromTheme {
  late Color color;
  late int themeIndex;

  ColorFromTheme(this.color, this.themeIndex);
}

class ThemeBag {
  late final ThemeData lightTheme;
  late final ThemeData darkTheme;

  ThemeBag({required this.lightTheme, required this.darkTheme});
}

class LocaleAndTheme {
  late int themeIndex;
  late Locale locale;

  LocaleAndTheme({required this.themeIndex, required this.locale});
}
