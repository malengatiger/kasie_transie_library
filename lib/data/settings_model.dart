class SettingsModel {
  String? associationId, locale;
  int? refreshRateInSeconds, themeIndex;

  SettingsModel({
    required this.locale,
    required this.themeIndex,
    required this.associationId,
    required this.refreshRateInSeconds});


  SettingsModel.fromJson(Map data) {
    associationId = data['associationId'];
    locale = data['locale'];
    refreshRateInSeconds = data['refreshRateInSeconds'];
    themeIndex = data['themeIndex'];

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'locale': locale,
      'refreshRateInSeconds': refreshRateInSeconds,
      'themeIndex': themeIndex,
      'associationId': associationId,
    };
    return map;
  }
}