import 'package:clever_11/cubit/splash/splash_cubit.dart';
import 'package:clever_11/cubit/splash/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class M11_SplashScreen extends StatelessWidget {
  const M11_SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => SplashCubit()..checkLoginStatus(),
        child: BlocListener<SplashCubit, SplashState>(
            listener: (context, state) {
              if (state == SplashState.home) {
                Navigator.pushReplacementNamed(context, '/m11_home');
              } else if (state == SplashState.login) {
                 Navigator.pushReplacementNamed(context, '/m11_login');
              }
            },
            child: Stack(
              children: [
                // Fullscreen background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/m1_login.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )));
  }
}
