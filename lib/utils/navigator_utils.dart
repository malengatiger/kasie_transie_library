import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigationUtils {

  static Future navigateTo({
    required BuildContext context,
    required Widget widget,
    PageTransitionType? transitionType,
    Duration? transitionDuration = const Duration(milliseconds: 500)
  }) async {
    var result = await Navigator.push(
      context,
      PageTransition(
        type: transitionType?? PageTransitionType.scale,
        duration: transitionDuration??const Duration(milliseconds: 1000),
        alignment: Alignment.bottomLeft,
        child: widget,
      ),
    );
    return result;
  }
}
