import 'package:flutter/material.dart';
import 'package:kasie_transie_library/auth/email_auth_signin.dart';
import 'package:kasie_transie_library/utils/image_grid.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../utils/functions.dart';

class EmailAuthContainer extends StatelessWidget {
  const EmailAuthContainer({super.key});

  _handleGoodSignIn(BuildContext context) {
    Navigator.of(context).pop(true);
  }
  _handleSignInError(BuildContext context) {
    Navigator.of(context).pop(false);
  }
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: [
        ScreenTypeLayout.builder(
          mobile: (_) {
            return Container(color: Colors.red);
          },
          tablet: (_) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                child: Row(
                  children: [
                    SizedBox(
                      width: (width / 2) - 64,
                      child: EmailAuthSignin(onGoodSignIn: () {
                        pp('..... on good sign in');
                       _handleGoodSignIn(context);
                      }, onSignInError: () {
                        pp('Sign in error');
                        _handleSignInError(context);
                      }),
                    ),
                    SizedBox(
                        width: (width / 2) - 64,
                        child: const ImageGrid(crossAxisCount: 2))
                  ],
                ));
          },
          desktop: (_) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 64, horizontal: 64),
                child: Row(
                  children: [
                    SizedBox(
                      width: (width / 2) - 64,
                      child: EmailAuthSignin(onGoodSignIn: () {
                        pp('on good sign in');
                        Navigator.of(context).pop(true);
                      }, onSignInError: () {
                        pp('$mm Sign in error');
                        Navigator.of(context).pop(false);
                        showErrorToast(message: 'Sign in failed', context: context);

                      }),
                    ),
                    SizedBox(
                        width: (width / 2) - 64,
                        child: const ImageGrid(crossAxisCount: 3))
                  ],
                ));
          },
        )
      ],
    )));
  }
  static const mm = '🥦🥦🥦 EmailAuthContainer 🥦';
}
