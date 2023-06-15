import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
Color getTextColorForBackground(Color backgroundColor) {
  if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
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
      color: Theme.of(context).primaryColor
  );
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

TextStyle myTextStyleSubtitle(BuildContext context) {
  return GoogleFonts.roboto(
    textStyle: Theme.of(context).textTheme.titleMedium,
    fontWeight: FontWeight.w600, fontSize: 20,

  );
}
TextStyle myTextStyleSubtitleSmall(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.titleMedium,
      fontWeight: FontWeight.w600, fontSize: 12
  );
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
    fontSize: 20.0, color: color,
  );
}
TextStyle myTextStyleMediumWithColor(BuildContext context, Color color) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.normal,
    fontSize: 20.0, color: color,
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
TextStyle myTextStyleMediumLargeWithColor(BuildContext context, Color color) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: 24);
}
TextStyle myTextStyleMediumLargeWithOpacity(BuildContext context, double opacity) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor.withOpacity(opacity),
      fontSize: 16);
}
TextStyle myTextStyleMediumLargePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor,
      fontSize: 24);
}
TextStyle myTextStyleTitlePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor,
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
TextStyle myNumberStyleWithSizeColor(BuildContext context, double fontSize, Color color) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: color,
      fontSize: fontSize);
}

TextStyle myNumberStyleBig(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900);
}

showSnackBar(
    {required String message,
      required BuildContext context,
      Color? backgroundColor,
      TextStyle? textStyle,
      Duration? duration,
      double? padding,
      double? elevation
    }) {
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
