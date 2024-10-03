
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/data_schemas.dart' as lib;
import '../l10n/translation_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

///select supported locale
class LocaleChooser extends StatefulWidget {
  const LocaleChooser(
      {super.key,
        required this.onSelected,
        required this.hint,
        required this.color});

  final Function(Locale, String) onSelected;
  final String hint;
  final Color color;

  @override
  State<LocaleChooser> createState() => LocaleChooserState();
}

class LocaleChooserState extends State<LocaleChooser> {
  String? english,
      french,
      portuguese,
      lingala,
      sotho,
      spanish,
      shona,
      swahili,
      tsonga,
      xhosa,
      zulu,
      yoruba,
      afrikaans,
      german,
      chinese;

  lib.SettingsModel? settingsModel;
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    super.initState();
    setTexts();
  }

  Future setTexts() async {
    settingsModel = prefs.getSettings();
    if (settingsModel?.locale != null) {
      final locale = settingsModel!.locale!;
      english = await translator.translate('en', locale);
      afrikaans = await translator.translate('af', locale);
      french = await translator.translate('fr', locale);
      portuguese = await translator.translate('pt', locale);
      lingala = await translator.translate('ig', locale);
      sotho = await translator.translate('st', locale);
      spanish = await translator.translate('es', locale);
      swahili = await translator.translate('sw', locale);
      tsonga = await translator.translate('ts', locale);
      xhosa = await translator.translate('xh', locale);
      zulu = await translator.translate('zu', locale);
      yoruba = await translator.translate('yo', locale);
      german = await translator.translate('de', locale);
      chinese = await translator.translate('zh', locale);
      shona = await translator.translate('sn', locale);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return settingsModel == null
        ? const SizedBox()
        : DropdownButton<Locale>(
        hint: Text(
          widget.hint,
          style: myTextStyleSmallWithColor(context, widget.color),
        ),
        items: [
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text(english == null ? 'English' : english!,
                style: myTextStyleSmall(context)),
          ),
          DropdownMenuItem(
              value: const Locale('zh'),
              child: Text(chinese == null ? 'Chinese' : chinese!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('af'),
              child: Text(afrikaans == null ? 'Afrikaans' : afrikaans!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('fr'),
              child: Text(french == null ? 'French' : french!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('de'),
              child: Text(german == null ? 'German' : german!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('pt'),
              child: Text(portuguese == null ? 'Portuguese' : portuguese!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('ig'),
              child: Text(lingala == null ? 'Lingala' : lingala!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('st'),
              child: Text(sotho == null ? 'Sotho' : sotho!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('es'),
              child: Text(spanish == null ? 'Spanish' : spanish!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('sn'),
              child: Text(shona == null ? 'Shona' : shona!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('sw'),
              child: Text(swahili == null ? 'Swahili' : swahili!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('ts'),
              child: Text(tsonga == null ? 'Tsonga' : tsonga!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('xh'),
              child: Text(xhosa == null ? 'Xhosa' : xhosa!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('yo'),
              child: Text(yoruba == null ? 'Yoruba' : yoruba!,
                  style: myTextStyleSmall(context))),
          DropdownMenuItem(
              value: const Locale('zu'),
              child: Text(zulu == null ? 'Zulu' : zulu!,
                  style: myTextStyleSmall(context))),
        ],
        onChanged: onChanged);
  }

  void onChanged(Locale? locale) async {
    pp('LocaleChooser 🌀🌀🌀🌀:onChanged: selected locale: '
        '${locale.toString()}');
    settingsModel =  prefs.getSettings();
    settingsModel!.locale = locale!.languageCode;

     prefs.saveSettings(settingsModel!);
    await setTexts();

    var language = 'English';
    switch (locale.languageCode) {
      case 'eng':
        language = english!;
        break;
      case 'af':
        language = afrikaans!;
        break;
      case 'fr':
        language = french!;
        break;
      case 'pt':
        language = portuguese!;
        break;
      case 'ig':
        language = lingala!;
        break;
      case 'es':
        language = spanish!;
        break;
      case 'st':
        language = sotho!;
        break;
      case 'sw':
        language = swahili!;
        break;
      case 'xh':
        language = xhosa!;
        break;
      case 'zu':
        language = zulu!;
        break;
      case 'yo':
        language = yoruba!;
        break;
      case 'de':
        language = german!;
        break;
      case 'zh':
        language = chinese!;
        break;
    }
    await setTexts();
    widget.onSelected(locale, language);
  }
}