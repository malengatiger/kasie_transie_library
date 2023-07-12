import 'dart:async';
import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';

import '../data/schemas.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

final ThemeBloc themeBloc = ThemeBloc();

class ThemeBloc {
  final mm = '🍎🍎🍎ThemeBloc 🍎🍎🍎: ';
  ThemeBloc() {
    pp('$mm ... ThemeBloc initializing ....');
    _initialize();
  }

  final StreamController<ColorAndLocale> themeStreamController =
      StreamController.broadcast();

  Stream<ColorAndLocale> get localeAndThemeStream =>
      themeStreamController.stream;

  ColorAndLocale? colorAndLocale;

  _initialize() async {
    colorAndLocale = await prefs.getColorAndLocale();
    colorAndLocale ??= ColorAndLocale(themeIndex: 0, locale: 'en');
    pp('\n$mm initialize: acquired settings: ....theme index: ${colorAndLocale!.themeIndex}');
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
    final cft = ColorFromTheme(bag.darkTheme.primaryColor, colorAndLocale.themeIndex);
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
        lightTheme: FlexThemeData.light(scheme: FlexScheme.redWine),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.redWine)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.barossa),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.barossa)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.green),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.green)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mallardGreen),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mallardGreen)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.red),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.red)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.blue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.blue)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.mango),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.mango)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.indigo),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.indigo)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.deepBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.deepBlue)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.hippieBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.hippieBlue)));
    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.deepPurple),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.deepPurple)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.espresso),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.espresso)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.barossa),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.barossa)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.bigStone),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.bigStone)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.damask),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.damask)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.purpleBrown),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.purpleBrown)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.wasabi),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.wasabi)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.rosewood),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.rosewood)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.sanJuanBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.sanJuanBlue)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.amber),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.amber)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.dellGenoa),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.dellGenoa)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.gold),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.gold)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.blueWhale),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.ebonyClay),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.money),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.money)));

    _themeBags.add(ThemeBag(
        lightTheme: FlexThemeData.light(scheme: FlexScheme.aquaBlue),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue)));
    _themeBags.add(
        ThemeBag(lightTheme: getMyThemeLight(), darkTheme: getMyThemeDark()));


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

ThemeData getMyThemeLight() {
  final td = ThemeData(
    indicatorColor: const Color(0xff00a6ed),
    primaryColor: const Color(0xFF424343),
    cardColor: const Color(0xffe4e4e4),
    scaffoldBackgroundColor: Colors.white,
    canvasColor: const Color(0xFF424343),
    splashColor: const Color(0xFF424343),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      actionsIconTheme: IconThemeData(color: Colors.black),
    ),
    brightness: Brightness.light,
  );

  return td;
}

ThemeData getMyThemeDark() {
  final td = ThemeData(
    indicatorColor: const Color(0xff00a6ed),
    primaryColor: const Color(0xfff4f3ee),
    cardColor: const Color(0xff222222),
    canvasColor: const Color(0xffffb400),
    scaffoldBackgroundColor: Colors.black,
    brightness: Brightness.dark,
    splashColor: const Color(0xffffb400),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black.withOpacity(0.6),
      actionsIconTheme: IconThemeData(color: Colors.white.withOpacity(0.4)),
    ),
  );
  return td;
}

class KhayaTheme {
  static const ColorScheme flexSchemeDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff9fc9ff),
    onPrimary: Color(0xff101314),
    primaryContainer: Color(0xff00325b),
    onPrimaryContainer: Color(0xffdfe7ee),
    secondary: Color(0xffffb59d),
    onSecondary: Color(0xff141210),
    secondaryContainer: Color(0xff872100),
    onSecondaryContainer: Color(0xfff4e4df),
    tertiary: Color(0xff86d2e1),
    onTertiary: Color(0xff0e1414),
    tertiaryContainer: Color(0xff004e59),
    onTertiaryContainer: Color(0xffdfeced),
    error: Color(0xffcf6679),
    onError: Color(0xff140c0d),
    errorContainer: Color(0xffb1384e),
    onErrorContainer: Color(0xfffbe8ec),
    background: Color(0xff191b1f),
    onBackground: Color(0xffeceded),
    surface: Color(0xff191b1f),
    onSurface: Color(0xffeceded),
    surfaceVariant: Color(0xff21262d),
    onSurfaceVariant: Color(0xffdcdcde),
    outline: Color(0xff9da3a3),
    shadow: Color(0xff000000),
    inverseSurface: Color(0xfff9fbff),
    onInverseSurface: Color(0xff131314),
    inversePrimary: Color(0xff536578),
    surfaceTint: Color(0xff9fc9ff),
  );

  var theme1 = ThemeData.dark();

  var themeLight = FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: Color(0xff004881),
          primaryContainer: Color(0xffd0e4ff),
          secondary: Color(0xffac3306),
          secondaryContainer: Color(0xffd9754f),
          tertiary: Color(0xff006875),
          tertiaryContainer: Color(0xff95f0ff),
          appBarColor: Color(0xffd9754f),
          error: Color(0xffb00020),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      themeDark = FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff9fc9ff),
          primaryContainer: Color(0xff00325b),
          secondary: Color(0xffffb59d),
          secondaryContainer: Color(0xff872100),
          tertiary: Color(0xff86d2e1),
          tertiaryContainer: Color(0xff004e59),
          appBarColor: Color(0xff872100),
          error: Color(0xffcf6679),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.lato().fontFamily,
      );
}
