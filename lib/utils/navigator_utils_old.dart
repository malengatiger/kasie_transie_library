

import 'package:flutter/material.dart';

void navigateWithFade(Widget widget, BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

Future navigateWithScale(Widget widget, BuildContext context) async {
  var res = await Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget,
      transitionsBuilder: (_, animation, __, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    ),
  );
  return res;
}
void navigateWithSlide(Widget widget, BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}
