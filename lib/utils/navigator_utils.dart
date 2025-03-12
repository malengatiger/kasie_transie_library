import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'functions.dart';

// class NavigationUtils {
//
//   static Future navigateTo({
//     required BuildContext context,
//     required Widget widget,
//     PageTransitionType? transitionType,
//     Duration? transitionDuration = const Duration(milliseconds: 500)
//   }) async {
//     var result = await Navigator.push(
//       context,
//       PageTransition(
//         type: transitionType?? PageTransitionType.scale,
//         duration: transitionDuration??const Duration(milliseconds: 1000),
//         alignment: Alignment.bottomLeft,
//         child: widget,
//       ),
//     );
//     return result;
//   }
// }

class NavigationUtils {
  static Future navigateTo({
    required BuildContext context,
    required Widget widget,
    PageTransitionType? transitionType,
    Duration? duration,
  }) async {
    pp('NavigationUtils: .... navigating to widget: ${widget.toString()}');
    return await Navigator.push(
      context,
      PageTransition(
        child: widget,
        type: transitionType ?? PageTransitionType.rightToLeft,
        alignment: Alignment.bottomLeft,
        curve: Curves.bounceIn,
        duration: duration ?? const Duration(milliseconds: 1000),
        settings: RouteSettings(name: widget.toStringShort()),
      ),
    );
  }
  static Future  navigateNormal(BuildContext context, Widget widget) async {
    pp('NavigationUtils: .... navigateNormal to widget: ${widget.toString()}');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
    return 1;
  }
}
