class ColorAndLocale {
  late int themeIndex;
  late String locale;

  ColorAndLocale({required this.themeIndex, required this.locale});

  ColorAndLocale.fromJson (Map map) {
    themeIndex = map['themeIndex'];
    locale = map['locale'];
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'themeIndex': themeIndex,
    };
  }
}
