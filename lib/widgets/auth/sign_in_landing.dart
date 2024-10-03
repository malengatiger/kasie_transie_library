import 'package:flutter/material.dart';

import '../../utils/functions.dart';

class SignInLanding extends StatelessWidget {
  const SignInLanding(
      {super.key,
      required this.welcome,
      required this.firstTime,
      required this.changeLanguage,
      required this.signInWithPhone,
      required this.startEmailLinkSignin,
      required this.onNavigateToEmailAuth,
      required this.onNavigateToPhoneAuth,
      required this.onNavigateToColor,
      required this.signInWithEmail});

  final String welcome,
      firstTime,
      changeLanguage,
      signInWithPhone,
      signInWithEmail,
      startEmailLinkSignin;

  final Function onNavigateToEmailAuth,
      onNavigateToPhoneAuth,
      onNavigateToColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 340,
            height: 300,
            child: Image.asset(
              'assets/ktlogo_red.png',
            )),
        const SizedBox(
          height: 64,
        ),
        Text(
          welcome,
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColorLight, 48),
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(
            firstTime,
            style: myTextStyleMedium(context),
          ),
        ),
        const SizedBox(
          height: 64,
        ),
        SizedBox(
          width: 240,
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: const WidgetStatePropertyAll(4.0),
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).primaryColorLight),
            ),
            onPressed: () {
              onNavigateToColor();
            },
            // icon: const Icon(Icons.language),

            child: Text(
              changeLanguage,
              style: myTextStyleSmallBlack(context),
            ),
          ),
        ),
        const SizedBox(
          height: 100,
        ),
        SizedBox(
          width: 320,
          child: ElevatedButton.icon(
              onPressed: () {
                onNavigateToPhoneAuth();
              },
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(8.0),
                backgroundColor:
                    WidgetStatePropertyAll(Theme.of(context).primaryColor),
              ),
              label: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  signInWithPhone,
                  style: myTextStyleSmallBlack(context),
                ),
              ),
              icon: const Icon(Icons.phone)),
        ),
        const SizedBox(
          height: 32,
        ),
        SizedBox(
          width: 320,
          child: ElevatedButton.icon(
              onPressed: () {
                onNavigateToEmailAuth();
              },
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(8.0),
                backgroundColor:
                    WidgetStatePropertyAll(Theme.of(context).primaryColor),
              ),
              label: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Sign In With Your Email',
                  style: myTextStyleSmallBlack(context),
                ),
              ),
              icon: const Icon(Icons.email)),
        ),
        Container(
          color: Theme.of(context).primaryColorLight,
          width: 160,
          height: 2,
        ),
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }
}
