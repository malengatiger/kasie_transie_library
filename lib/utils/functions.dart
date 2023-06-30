import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';


pp(dynamic msg) {
  var fmt = DateFormat('dd/MM/HH:mm:ss');
  var time = fmt.format(DateTime.now());
  if (kReleaseMode) {
    return;
  }
  if (kDebugMode) {
    if (msg is String) {
      debugPrint('$time ==> $msg');
    } else {
      print('$time ==> $msg');
    }
  }
}

String getFmtDate(String date, String locale) {
  initializeDateFormatting("en","somefile");
  String mLocale = getValidLocale(locale);
  Future.delayed(const Duration(milliseconds: 10));

  DateTime now = DateTime.parse(date).toLocal();
  final format = DateFormat("EEEE dd MMMM yyyy  HH:mm:ss", mLocale);
  final formatUS = DateFormat("EEEE MMMM dd yyyy  HH:mm:ss", mLocale);
  if (mLocale.contains('en_US')) {
    final String result = formatUS.format(now);
    return result;
  } else {
    final String result = format.format(now);
    return result;
  }
}
String getFormattedDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.yMMMd();
    return format.format(d);
  } catch (e) {
    return date;
  }
}
String getFormattedDateLong(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat("EEEE, dd MMMM yyyy HH:mm");
    return format.format(d);
  } catch (e) {
    return date;
  }
}
String getStringColor(Color color) {
  var stringColor = 'black';
  switch (color) {
    case Colors.white:
      stringColor = 'white';
      break;
    case Colors.red:
      stringColor = 'red';
      break;
    case Colors.black:
      stringColor = 'black';
      break;
    case Colors.amber:
      stringColor = 'amber';
      break;
    case Colors.yellow:
      stringColor = 'yellow';
      break;
    case Colors.pink:
      stringColor = 'pink';
      break;
    case Colors.purple:
      stringColor = 'purple';
      break;
    case Colors.green:
      stringColor = 'green';
      break;
    case Colors.teal:
      stringColor = 'teal';
      break;
    case Colors.indigo:
      stringColor = 'indigo';
      break;
    case Colors.blue:
      stringColor = 'blue';
      break;
    case Colors.orange:
      stringColor = 'orange';
      break;

    default:
      stringColor = 'black';
      break;
  }
  return stringColor;
}

Color getColor(String stringColor) {
  switch (stringColor) {
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'black':
      return Colors.black;
    case 'amber':
      return Colors.amber;
    case 'yellow':
      return Colors.yellow;
    case 'pink':
      return Colors.pink;
    case 'purple':
      return Colors.purple;
    case 'green':
      return Colors.green;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    case 'blue':
      return Colors.blue;
    case 'orange':
      return Colors.orange;
    default:
      return Colors.black;
  }
}


String getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}

String getFormattedDateHour(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = DateFormat.Hm();
    return format.format(d);
  }
}
String getValidLocale(String locale) {
  switch (locale) {
    case 'af':
      return 'af_ZA';
    case 'en':
      return 'en';
    case 'es':
      return 'es';
    case 'pt':
      return 'pt';
    case 'fr':
      return 'fr';
    case 'st':
      return 'en_ZA';
    case 'ts':
      return 'en_ZA';
    case 'xh':
      return 'en_ZA';
    case 'zu':
      return 'zu_ZA';
    case 'sn':
      return 'en_GB';
    case 'yo':
      return 'en_NG';
    case 'sw':
      return 'sw_KE';
    case 'de':
      return 'de';
    case 'zh':
      return 'zh';
    default:
      return 'en_US';
  }
}

String getFormattedTime({required int timeInSeconds}) {
  int sec = timeInSeconds % 60;
  int min = (timeInSeconds / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second";
}
Color getTextColorForBackground(Color backgroundColor) {
  if (ThemeData.estimateBrightnessForColor(backgroundColor) ==
      Brightness.dark) {
    return Colors.white;
  }

  return Colors.black;
}

getRoundedBorder({required double radius}) {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}

TextStyle myTextStyleSmall(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
  );
}

TextStyle myTextStyleSmallBlackBold(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.bodySmall,
      // fontWeight: FontWeight.w200,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleSmallBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.w600,
  );
}

TextStyle myTextStyleSmallBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleSmallPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleTiny(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.normal,
    fontSize: 10,
  );
}

TextStyle myTextStyleTiniest(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.normal,
    fontSize: 8,
  );
}

TextStyle myTextStyleTinyBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );
}

TextStyle myTextStyleTinyBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleTinyPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleSmallBlack(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      color: Colors.black);
}

TextStyle myTextStyleMedium(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.normal,
  );
}
TextStyle myTextStyleMediumBlack(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.normal,
    color: Colors.black
  );
}

TextStyle myTextStyleSubtitle(BuildContext context) {
  return GoogleFonts.roboto(
    textStyle: Theme.of(context).textTheme.titleMedium,
    fontWeight: FontWeight.w600,
    fontSize: 20,
  );
}

TextStyle myTextStyleSubtitleSmall(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.titleMedium,
      fontWeight: FontWeight.w600,
      fontSize: 12);
}

TextStyle myTextStyleMediumGrey(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade600);
}

TextStyle myTextStyleMediumPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleMediumBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.w900,
      fontSize: 20,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleMediumBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.w900,
    fontSize: 16.0,
  );
}

TextStyle myTextStyleMediumBoldWithColor(BuildContext context, Color color) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: color,
  );
}

TextStyle myTextStyleMediumWithColor(BuildContext context, Color color) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.normal,
    fontSize: 20.0,
    color: color,
  );
}

TextStyle myTitleTextStyle(BuildContext context, Color color) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.w900,
    color: color,
    fontSize: 20.0,
  );
}

TextStyle myTextStyleSmallWithColor(BuildContext context, Color color) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    color: color,
  );
}

TextStyle myTextStyleMediumBoldGrey(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
    color: Colors.grey.shade600,
    fontSize: 13.0,
  );
}

TextStyle myTextStyleLarge(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 28);
}

TextStyle myTextStyleLargeWithColor(BuildContext context, Color color) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: 28);
}

TextStyle myTextStyleMediumLarge(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 24);
}

TextStyle myTextStyleMediumLargeWithSize(BuildContext context, double size) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: size);
}
TextStyle myTextStyleMediumLargeWithColor(BuildContext context, Color color, double size) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: size);
}

TextStyle myTextStyleMediumLargeWithOpacity(
    BuildContext context, double opacity) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor.withOpacity(opacity),
      fontSize: 16);
}

TextStyle myTextStyleMediumLargePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor,
      fontSize: 24);
}

TextStyle myTextStyleTitlePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor,
      fontSize: 20);
}

TextStyle myTextStyleHeader(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 34);
}

TextStyle myTextStyleLargePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleLargerPrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 32,
      color: Theme.of(context).primaryColor);
}

TextStyle myNumberStyleSmall(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleMedium(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleMediumPrimaryColor(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myNumberStyleLarge(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyLarge,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleLargerPrimaryColor(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.w900,
      fontSize: 28);
}
TextStyle myNumberStyleLargerWithColor(Color color, double fontSize, BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      color: color,
      fontWeight: FontWeight.w900,
      fontSize: fontSize);
}

TextStyle myNumberStyleLargerPrimaryColorLight(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColorLight,
      fontSize: 28);
}

TextStyle myNumberStyleLargerPrimaryColorDark(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColorDark,
      fontSize: 28);
}

TextStyle myNumberStyleLargest(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 36);
}

TextStyle myNumberStyleWithSizeColor(
    BuildContext context, double fontSize, Color color) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: fontSize);
}

TextStyle myNumberStyleBig(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900);
}

JsonDecoder decoder = const JsonDecoder();
JsonEncoder encoder = const JsonEncoder.withIndent('  ');

void prettyJson(String input) {
  var object = decoder.convert(input);
  var prettyString = encoder.convert(object);
  prettyString.split('\n').forEach((element) => myPrint(element));
}
void myPrettyJsonPrint(Map map) {
  printPrettyJson(map);
}

myPrint(element) {
  if (kDebugMode) {
    print(element);
  }
}

showSnackBar(
    {required String message,
    required BuildContext context,
    Color? backgroundColor,
    TextStyle? textStyle,
    Duration? duration,
    double? padding,
    double? elevation}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: duration ?? const Duration(seconds: 5),
    backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
    showCloseIcon: true,
    elevation: elevation ?? 8,
    content: Padding(
      padding: EdgeInsets.all(padding ?? 8),
      child: Text(
        message,
        style: textStyle ?? myTextStyleMediumBold(context),
      ),
    ),
  ));
}
Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}
showToast(
    {required String message,
      required BuildContext context,
      Color? backgroundColor,
      TextStyle? textStyle,
      Duration? duration,
      double? padding,
      ToastGravity? toastGravity}) {
  FToast fToast = FToast();
  const mm = 'FunctionsAndShit: 💀 💀 💀 💀 💀 : ';
  try {
    fToast.init(context);
  } catch (e) {
    pp('$mm FToast may already be initialized');
  }
  Widget toastContainer = Container(
    width: 320,
    padding: EdgeInsets.symmetric(
        horizontal: padding ?? 8.0,
        vertical: padding ?? 8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: backgroundColor ?? Colors.white,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: textStyle ?? myTextStyleSmall(context),
          ),
        ),
      ],
    ),
  );

  try {
    fToast.showToast(
      child: toastContainer,
      gravity: toastGravity ?? ToastGravity.CENTER,
      toastDuration: duration ?? const Duration(seconds: 3),
    );
  } catch (e) {
    pp('$mm 👿👿👿👿👿 we have a small TOAST problem, Boss! - 👿 $e');
  }
}

Future<String> getStringFromAssets(String path) async {
  pp('getStringFromAssets: locale: $path');
  final stringData = await rootBundle.loadString('assets/l10n/$path.json');
  return stringData;
}

const lorem =
    'Having a centralized platform to collect multimedia information and build video, audio, and photo timelines '
    'can be a valuable tool for managers and executives to monitor long-running field operations. '
    'This can provide a visual representation of the progress and status of field operations and help in '
    'tracking changes over time. Timelines can also be used to identify any bottlenecks or issues that arise during field operations, allowing for quick and effective problem-solving. '
    'The multimedia information collected can also be used for training and review purposes, allowing for '
    'continuous improvement and optimization of field operations. Overall, building multimedia timelines '
    'can provide valuable insights and information for managers and executives to make informed decisions and improve '
    'the overall efficiency of field operations.\n\nThere are many use cases for monitoring and managing initiatives '
    'using mobile devices and cloud platforms. The combination of mobile devices and cloud-based solutions can greatly improve '
    'the efficiency and effectiveness of various initiatives, including infrastructure building projects, events, conferences, '
    'school facilities, and ongoing activities of all types. By using mobile devices, field workers can collect and share multimedia information in real-time, '
    'allowing for better coordination and communication. The use of cloud platforms can also provide additional benefits, '
    'such as field worker authentication, cloud push messaging systems, data storage, and databases. This can help in centralizing information, '
    'reducing the reliance on manual processes and paperwork, and improving the ability to make informed decisions and respond to changes in real-time. '
    'Overall, utilizing mobile devices and cloud platforms can provide a '
    'powerful solution for monitoring and managing various initiatives in a more efficient and effective manner.';
