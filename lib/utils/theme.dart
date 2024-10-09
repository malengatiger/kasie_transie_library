import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282345728),
      surfaceTint: Color(4282345728),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4285509145),
      onPrimaryContainer: Color(4278653440),
      secondary: Color(4283131434),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4291883685),
      onSecondaryContainer: Color(4281881111),
      tertiary: Color(4278217808),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280594567),
      onTertiaryContainer: Color(4278194442),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294441962),
      onSurface: Color(4279835923),
      onSurfaceVariant: Color(4282534199),
      outline: Color(4285692518),
      outlineVariant: Color(4290955954),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217575),
      inversePrimary: Color(4288141637),
      primaryFixed: Color(4289918559),
      onPrimaryFixed: Color(4279246848),
      primaryFixedDim: Color(4288141637),
      onPrimaryFixedVariant: Color(4281290496),
      secondaryFixed: Color(4291620513),
      onSecondaryFixed: Color(4279246848),
      secondaryFixedDim: Color(4289843592),
      onSecondaryFixedVariant: Color(4281617940),
      tertiaryFixed: Color(4286380491),
      onTertiaryFixed: Color(4278198550),
      tertiaryFixedDim: Color(4284341424),
      onTertiaryFixedVariant: Color(4278210876),
      surfaceDim: Color(4292402380),
      surfaceBright: Color(4294441962),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112741),
      surfaceContainer: Color(4293718239),
      surfaceContainerHigh: Color(4293323482),
      surfaceContainerHighest: Color(4292928724),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281092864),
      surfaceTint: Color(4282345728),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283400704),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281354768),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284513598),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278209848),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278224228),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441962),
      onSurface: Color(4279835923),
      onSurfaceVariant: Color(4282271028),
      outline: Color(4284113487),
      outlineVariant: Color(4285955433),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217575),
      inversePrimary: Color(4288141637),
      primaryFixed: Color(4283400704),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282279680),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284513598),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282999847),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278224228),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278217038),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402380),
      surfaceBright: Color(4294441962),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112741),
      surfaceContainer: Color(4293718239),
      surfaceContainerHigh: Color(4293323482),
      surfaceContainerHighest: Color(4292928724),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4279510784),
      surfaceTint: Color(4282345728),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281092864),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279510784),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281354768),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200348),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278209848),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441962),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280231447),
      outline: Color(4282271028),
      outlineVariant: Color(4282271028),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217575),
      inversePrimary: Color(4290772850),
      primaryFixed: Color(4281092864),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4280038144),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281354768),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280038144),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278209848),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278203429),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402380),
      surfaceBright: Color(4294441962),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112741),
      surfaceContainer: Color(4293718239),
      surfaceContainerHigh: Color(4293323482),
      surfaceContainerHighest: Color(4292928724),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288141637),
      surfaceTint: Color(4288141637),
      onPrimary: Color(4280235776),
      primaryContainer: Color(4283400704),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4289843592),
      onSecondary: Color(4280235776),
      secondaryContainer: Color(4281091596),
      onSecondaryContainer: Color(4290633364),
      tertiary: Color(4284341424),
      onTertiary: Color(4278204456),
      tertiaryContainer: Color(4278224228),
      onTertiaryContainer: Color(4294967295),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309579),
      onSurface: Color(4292928724),
      onSurfaceVariant: Color(4290955954),
      outline: Color(4287403134),
      outlineVariant: Color(4282534199),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928724),
      inversePrimary: Color(4282345728),
      primaryFixed: Color(4289918559),
      onPrimaryFixed: Color(4279246848),
      primaryFixedDim: Color(4288141637),
      onPrimaryFixedVariant: Color(4281290496),
      secondaryFixed: Color(4291620513),
      onSecondaryFixed: Color(4279246848),
      secondaryFixedDim: Color(4289843592),
      onSecondaryFixedVariant: Color(4281617940),
      tertiaryFixed: Color(4286380491),
      onTertiaryFixed: Color(4278198550),
      tertiaryFixedDim: Color(4284341424),
      onTertiaryFixedVariant: Color(4278210876),
      surfaceDim: Color(4279309579),
      surfaceBright: Color(4281744175),
      surfaceContainerLowest: Color(4278914823),
      surfaceContainerLow: Color(4279835923),
      surfaceContainer: Color(4280099095),
      surfaceContainerHigh: Color(4280757025),
      surfaceContainerHighest: Color(4281480747),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288404809),
      surfaceTint: Color(4288141637),
      onPrimary: Color(4278983168),
      primaryContainer: Color(4284784900),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290106764),
      onSecondary: Color(4278983168),
      secondaryContainer: Color(4286356055),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4284670132),
      onTertiary: Color(4278197010),
      tertiaryContainer: Color(4278559868),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309579),
      onSurface: Color(4294573548),
      onSurfaceVariant: Color(4291219126),
      outline: Color(4288587408),
      outlineVariant: Color(4286482033),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928724),
      inversePrimary: Color(4281291008),
      primaryFixed: Color(4289918559),
      onPrimaryFixed: Color(4278719488),
      primaryFixedDim: Color(4288141637),
      onPrimaryFixedVariant: Color(4280499456),
      secondaryFixed: Color(4291620513),
      onSecondaryFixed: Color(4278719488),
      secondaryFixedDim: Color(4289843592),
      onSecondaryFixedVariant: Color(4280564995),
      tertiaryFixed: Color(4286380491),
      onTertiaryFixed: Color(4278195469),
      tertiaryFixedDim: Color(4284341424),
      onTertiaryFixedVariant: Color(4278206253),
      surfaceDim: Color(4279309579),
      surfaceBright: Color(4281744175),
      surfaceContainerLowest: Color(4278914823),
      surfaceContainerLow: Color(4279835923),
      surfaceContainer: Color(4280099095),
      surfaceContainerHigh: Color(4280757025),
      surfaceContainerHighest: Color(4281480747),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294246367),
      surfaceTint: Color(4288141637),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4288404809),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294246367),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290106764),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293787636),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4284670132),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309579),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294377189),
      outline: Color(4291219126),
      outlineVariant: Color(4291219126),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928724),
      inversePrimary: Color(4279906304),
      primaryFixed: Color(4290181987),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4288404809),
      onPrimaryFixedVariant: Color(4278983168),
      secondaryFixed: Color(4291883685),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290106764),
      onSecondaryFixedVariant: Color(4278983168),
      tertiaryFixed: Color(4286643663),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4284670132),
      onTertiaryFixedVariant: Color(4278197010),
      surfaceDim: Color(4279309579),
      surfaceBright: Color(4281744175),
      surfaceContainerLowest: Color(4278914823),
      surfaceContainerLow: Color(4279835923),
      surfaceContainer: Color(4280099095),
      surfaceContainerHigh: Color(4280757025),
      surfaceContainerHighest: Color(4281480747),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
