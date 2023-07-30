import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path_provider/path_provider.dart';
import 'package:pretty_json/pretty_json.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'emojis.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:image/image.dart' as img;

pp(dynamic msg) {
  var time = getFormattedDateHour(DateTime.now().toIso8601String());
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

Future<String> getFmtDate(String date, String locale) async {
  await initializeDateFormatting("en", "somefile");
  String mLocale = getValidLocale(locale);
  Future.delayed(const Duration(milliseconds: 10));

  DateTime now = DateTime.parse(date).toLocal();
  final format = intl.DateFormat("EEEE dd MMMM yyyy  HH:mm:ss", mLocale);
  final formatUS = intl.DateFormat("EEEE MMMM dd yyyy  HH:mm:ss", mLocale);
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
    var format = intl.DateFormat.yMMMd();
    return format.format(d);
  } catch (e) {
    return date;
  }
}

String getFormattedDateLong(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = intl.DateFormat("EEEE, dd MMMM yyyy HH:mm");
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

Random random = Random(DateTime.now().millisecondsSinceEpoch);

(Color, String) getRandomColor() {
  final colors = [
    'white',
    'red',
    'black',
    'amber',
    'yellow',
    'pink',
    'purple',
    'green',
    'teal',
    'indigo',
    'blue',
    'orange'
  ];
  final index = random.nextInt(colors.length - 1);
  final stringColor = colors.elementAt(index);
  switch (stringColor) {
    case 'white':
      return (Colors.white, 'white');
    case 'red':
      return (Colors.red, 'red');
    case 'black':
      return (Colors.black, 'black');
    case 'amber':
      return (Colors.amber, 'amber');
    case 'yellow':
      return (Colors.yellow, 'yellow');
    case 'pink':
      return (Colors.pink, 'pink');
    case 'purple':
      return (Colors.purple, 'purple');
    case 'green':
      return (Colors.green, 'green');
    case 'teal':
      return (Colors.teal, 'teal');
    case 'indigo':
      return (Colors.indigo, 'indigo');
    case 'blue':
      return (Colors.blue, 'blue');
    case 'orange':
      return (Colors.orange, 'orange');
    default:
      return (Colors.black, 'black');
  }
}

Future<File> getPhotoThumbnail({required File file}) async {
  final Directory directory = await getApplicationDocumentsDirectory();

  img.Image? image = img.decodeImage(file.readAsBytesSync());
  var thumbnail = img.copyResize(image!, width: 160);
  const slash = '/thumbnail_';

  final File mFile = File(
      '${directory.path}$slash${DateTime.now().millisecondsSinceEpoch}.jpg');
  var thumb = mFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 100));
  var len = await thumb.length();
  pp('🔷🔷 photo thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
  return thumb;
}

Future<File> getVideoThumbnail(File file) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  var path = 'possibleVideoThumb_${DateTime.now().toIso8601String()}.jpg';
  const slash = '/';
  final thumbFile = File('${directory.path}$slash$path');

  try {
    final data = await vt.VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: vt.ImageFormat.JPEG,
      maxWidth: 128,
      quality: 100,
    );
    await thumbFile.writeAsBytes(data!);
    pp('🔷🔷Video thumbnail created. length: ${await thumbFile.length()} 🔷🔷🔷');
    return thumbFile;
  } catch (e) {
    pp('ERROR: $e');
    var m = await getImageFileFromAssets('assets/intro/small.jpg');
    return m;
  }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

String getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}

String getThisDeviceType() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = [" bytes", " KB", " MB", " GB", " TB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

double getFileSizeInMB({required int bytes, int decimals = 0}) {
  var i = (log(bytes) / log(1024)).floor();
  var size = (bytes / pow(1024, i));
  return size;
}

String getFormattedDateHour(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = intl.DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = intl.DateFormat.Hm();
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
  var duration = Duration(seconds: timeInSeconds);
  return _printDuration(duration);
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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

getDefaultRoundedBorder() {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0));
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
      color: Colors.black);
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

TextStyle myTextStyleMediumBoldWithColor(
    {required BuildContext context, required Color color, double? fontSize}) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.w900,
    fontSize: fontSize == null ? 18.0 : fontSize!,
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

TextStyle myTextStyleMediumLarge(BuildContext context, double? size) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: size == null ? 24 : size!);
}

TextStyle myTextStyleMediumLargeWithSize(BuildContext context, double size) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: size);
}

TextStyle myTextStyleMediumLargeWithColor(
    BuildContext context, Color color, double size) {
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

TextStyle myNumberStyleLargerWithColor(
    Color color, double fontSize, BuildContext context) {
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

Future<BitmapDescriptor> getMarkerBitmap(int size,
    {String? text,
    required String color,
    required Color borderColor,
    required double fontSize,
    required FontWeight fontWeight}) async {

  pp('color coming in: $color ');
  if (kIsWeb) size = (size / 2).floor();
  var textColor = Colors.white;
  switch (color) {
    case 'white':
      textColor = Colors.black;
      break;
    case 'yellow':
      textColor = Colors.black;
      break;
    case 'amber':
      textColor = Colors.black;
      break;

  }
  pp('color object calculated: ${textColor.toString()} ');

  final style = TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: textColor,
  );
  final mainColor = getColor(color);

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint1 = Paint()..color = mainColor;
  final Paint paint2 = Paint()..color = borderColor;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

  if (text != null) {
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: style,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );
  }

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ui.ImageByteFormat.png) as ByteData;

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  var byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

Future<BitmapDescriptor> getBitmapDescriptor(
    {required String path, required int width, required String color}) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  var byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);

  Uint8List m = byteData!.buffer.asUint8List();

  // img.colorOffset(
  //   doneImg!,
  //   red: rgb!.red,
  //   green: rgb.green,
  //   blue: rgb.blue,
  // );
  // final doneImg = img.copyResize(doneImg, width: width);
  // final Uint8List doneIconColorful =
  //     Uint8List.fromList(img.encodePng(doneImg));

  BitmapDescriptor doneBM = BitmapDescriptor.fromBytes(m);
  return doneBM;
}

final colorHashMap = HashMap<String, MyRGB>();
void _buildColorHashMap() {
  colorHashMap.clear();
  colorHashMap['red'] = MyRGB(red: 255, green: 0, blue: 0);
  colorHashMap['white'] = MyRGB(red: 255, green: 255, blue: 255);
  colorHashMap['black'] = MyRGB(red: 0, green: 0, blue: 0);
  colorHashMap['pink'] = MyRGB(red: 255, green: 20, blue: 147);
  colorHashMap['blue'] = MyRGB(red: 0, green: 0, blue: 255);
  colorHashMap['teal'] = MyRGB(red: 0, green: 128, blue: 128);
  colorHashMap['green'] = MyRGB(red: 0, green: 128, blue: 0);
  colorHashMap['amber'] = MyRGB(red: 255, green: 215, blue: 0);
  colorHashMap['indigo'] = MyRGB(red: 75, green: 0, blue: 130);
  colorHashMap['purple'] = MyRGB(red: 128, green: 0, blue: 128);
  colorHashMap['yellow'] = MyRGB(red: 255, green: 255, blue: 0);
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
        horizontal: padding ?? 8.0, vertical: padding ?? 8.0),
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
  final mPath = 'assets/l10n/$path.json';

  pp('${E.blueDot}${E.blueDot}${E.blueDot} getStringFromAssets: locale: $mPath');
  final stringData = await rootBundle.loadString(mPath);
  // pp('${E.blueDot}${E.blueDot}${E.blueDot} getStringFromAssets: stringData: $stringData');

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

class MyRGB {
  late int red, green, blue;

  MyRGB({required this.red, required this.green, required this.blue});
}
