import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
        'assets/Logo_Anim.webp',
        gaplessPlayback: true,
      ),
      splashIconSize: 800,
      centered: true,
      nextScreen: const HomePage(),
      backgroundColor: Colors.black,
      duration: 15000,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
