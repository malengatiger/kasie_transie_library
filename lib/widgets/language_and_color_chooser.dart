import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:badges/badges.dart' as bd;
import 'package:responsive_builder/responsive_builder.dart';
import '../bloc/theme_bloc.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

class LanguageAndColorChooser extends StatefulWidget {
  const LanguageAndColorChooser({Key? key, required this.onLanguageChosen}) : super(key: key);

  final Function onLanguageChosen;
  @override
  LanguageAndColorChooserState createState() => LanguageAndColorChooserState();
}

class LanguageAndColorChooserState extends State<LanguageAndColorChooser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🌸🌸🌸🌸🌸🌸 LanguageAndColorChooser 🌸🌸';
  List<ColorFromTheme> colors = [];
  List<LangBag> languageBags = [];
  bool busy = false;
  late ColorAndLocale colorAndLocale;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    getColors();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getColors() async {
    //todo - switch dark & light
    setState(() {
      busy = true;
    });
    try {
      colors = SchemeUtil.getDarkThemeColors();
      colorAndLocale = await prefs.getColorAndLocale();
      colorFromTheme = SchemeUtil.getColorFromTheme(colorAndLocale);
      langBag = LangBag(
        language: await translator.translate(colorAndLocale.locale, locale),
        index: 0,
        locale: colorAndLocale.locale,
      );
      await getLanguages();
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  var locale = 'en';
  Future getLanguages() async {
    setState(() {
      busy = true;
    });

    try {
      languageBags.clear();
      languageBags.add(LangBag(
        language: await translator.translate("en", locale),
        index: 0,
        locale: 'en',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("af", locale),
        index: 1,
        locale: 'af',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("fr", locale),
        index: 2,
        locale: 'fr',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("es", locale),
        index: 3,
        locale: 'es',
      ));

      languageBags.add(LangBag(
        language: await translator.translate("pt", locale),
        index: 4,
        locale: 'pt',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("de", locale),
        index: 5,
        locale: 'de',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("ts", locale),
        index: 6,
        locale: 'ts',
      ));

      languageBags.add(LangBag(
        language: await translator.translate("st", locale),
        index: 7,
        locale: 'st',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("zu", locale),
        index: 8,
        locale: 'zu',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("xh", locale),
        index: 9,
        locale: 'xh',
      ));

      languageBags.add(LangBag(
        language: await translator.translate("zh", locale),
        index: 10,
        locale: 'zh',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("yo", locale),
        index: 11,
        locale: 'yo',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("sw", locale),
        index: 12,
        locale: 'sw',
      ));

      languageBags.add(LangBag(
        language: await translator.translate("sn", locale),
        index: 13,
        locale: 'sn',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("ig", locale),
        index: 14,
        locale: 'ig',
      ));

      pp('$mm language bags built up: ${languageBags.length}');
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  ColorFromTheme? colorFromTheme;

  void onColorChosen(ColorFromTheme colorFromTheme) async {
    pp('$mm onColorChosen, index: ${colorFromTheme.themeIndex}');
    colorAndLocale.themeIndex = colorFromTheme.themeIndex;
    prefs.saveColorAndLocale(colorAndLocale);
    themeBloc.changeColorAndLocale(colorAndLocale);
    setState(() {
      this.colorFromTheme = colorFromTheme;
    });
  }

  LangBag? langBag;

  Future<void> onLanguageChosen(LangBag bag) async {
    pp('$mm ......... onLanguageChosen, language: ${bag.language}');
    colorAndLocale.locale = bag.locale;
    prefs.saveColorAndLocale(colorAndLocale);
    locale = bag.locale;
    themeBloc.changeColorAndLocale(colorAndLocale);
    await getLanguages();
    setState(() {
      langBag = bag;
    });

    widget.onLanguageChosen();

  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final width = MediaQuery.of(context).size.width;
    final type = getThisDeviceType();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          title: Text(
            'Language & Colour',
            style: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 24),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop(colorAndLocale);
                },
                icon: const Icon(Icons.check)),
          ],
          bottom: PreferredSize(
              preferredSize:  Size.fromHeight(type == 'phone'? 64: 100),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: type == 'phone'? 100.0 : 200.0,
                        height: 32,
                        color: colorFromTheme == null
                            ? Colors.grey
                            : colorFromTheme!.color,
                      ),
                      const SizedBox(
                        width: 28,
                      ),
                      langBag == null
                          ? Text(
                              'English',
                              style: myTextStyleMediumBoldGrey(context),
                            )
                          : Text(
                              langBag!.language,
                              style: myTextStyleMediumLargeWithColor(
                                  context,
                                  colorFromTheme == null
                                      ? Colors.grey
                                      : colorFromTheme!.color,
                                  24),
                            )
                    ],
                  ),
                   SizedBox(
                    height: type == 'phone'? 16: 32,
                  ),
                ],
              )),
        ),
        body: busy
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    backgroundColor: Colors.pink,
                  ),
                ),
              )
            : ScreenTypeLayout.builder(
                tablet: (ctx) {
                   return OrientationLayoutBuilder(
                       landscape: (ctx){
                         return Center(
                             child: SizedBox(
                               height: height,
                               child: Row(
                                 children: [
                                   SizedBox(
                                       width: (width /2),
                                       child: Card(
                                         shape: getDefaultRoundedBorder(),
                                         elevation: 8,
                                         child: Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: ColorGrid(
                                               colors: colors,
                                               onColorChosen: (c) {
                                                 onColorChosen(c);
                                               }, crossAxisCount: 6,),
                                         ),
                                       )),
                                   const SizedBox(
                                     width: 8,
                                   ),
                                   SizedBox(
                                     width: (width /2) - 60,
                                     child: LanguageList(
                                         languageBags: languageBags,
                                         onLanguageChosen: (l) {
                                           onLanguageChosen(l);
                                         }),
                                   ),
                                 ],
                               ),
                             ));
                       },
                       portrait: (ctx){
                     return Center(
                         child: SizedBox(
                           height: height,
                           child: Row(
                             children: [
                               SizedBox(
                                   width: (width /2) - 40,
                                   child: Card(
                                     elevation: 8,
                                     shape: getDefaultRoundedBorder(),
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: ColorGrid(
                                         crossAxisCount: 4,
                                           colors: colors,
                                           onColorChosen: (c) {
                                             onColorChosen(c);
                                           }),
                                     ),
                                   )),
                               const SizedBox(
                                 width: 8,
                               ),
                               SizedBox(
                                 width: (width /2),
                                 child: LanguageList(
                                     languageBags: languageBags,
                                     onLanguageChosen: (l) {
                                       onLanguageChosen(l);
                                     }),
                               ),
                             ],
                           ),
                         ));
                   });
                },
                mobile: (ctx) {
                  return Center(
                      child: SizedBox(
                    height: height,
                    child: Row(
                      children: [
                        SizedBox(
                            width: (width /2),
                            child: ColorGrid(
                              crossAxisCount: 3,
                                colors: colors,
                                onColorChosen: (c) {
                                  onColorChosen(c);
                                })),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: (width /2),
                          child: LanguageList(
                              languageBags: languageBags,
                              onLanguageChosen: (l) {
                                onLanguageChosen(l);
                              }),
                        ),
                      ],
                    ),
                  ));
                },
              ),
      ),
    );
  }
}

class LanguageList extends StatelessWidget {
  const LanguageList(
      {Key? key, required this.languageBags, required this.onLanguageChosen})
      : super(key: key);
  final List<LangBag> languageBags;
  final Function(LangBag) onLanguageChosen;

  @override
  Widget build(BuildContext context) {
    languageBags.sort((a, b) => a.language.compareTo(b.language));
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: bd.Badge(
          badgeContent: Text('${languageBags.length}'),
          position: bd.BadgePosition.bottomEnd(bottom: -2, end: -12),
          badgeStyle: bd.BadgeStyle(
            padding: const EdgeInsets.all(12),
            // badgeColor: Colors.teal.shade900,
            badgeColor: Theme.of(context).primaryColor,
          ),
          child: ListView.builder(
              itemCount: languageBags.length,
              itemBuilder: (ctx, index) {
                final l = languageBags.elementAt(index);
                return GestureDetector(
                    onTap: () async {
                      final m = await translator.translate(l.locale, l.locale);
                      pp('${E.redDot} language picked: ${l.language} translated to $m');
                      l.language = m;
                      onLanguageChosen(l);
                    },
                    child: Card(
                        shape: getRoundedBorder(radius: 12),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(l.language),
                        )));
              }),
        ),
      ),
    );
  }
}

class ColorGrid extends StatelessWidget {
  const ColorGrid({Key? key, required this.colors, required this.onColorChosen, required this.crossAxisCount})
      : super(key: key);

  final List<ColorFromTheme> colors;
  final Function(ColorFromTheme) onColorChosen;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GridView.builder(
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 2, mainAxisSpacing: 2, crossAxisCount: crossAxisCount),
          itemCount: colors.length,
          itemBuilder: (ctx, index) {
            final c = colors.elementAt(index);
            return GestureDetector(
              onTap: () {
                onColorChosen(c);
              },
              child: Container(
                color: c.color,
              ),
            );
          }),
    );
  }
}

class LangBag {
  late String language;
  late int index;
  late String locale;

  LangBag({required this.language, required this.index, required this.locale});
}
