import 'package:flutter/material.dart';
import 'package:clever_11/presentation/screens/contest/create_team_screen.dart';
import 'package:clever_11/presentation/screens/c11_profile/c11_profile.dart';
import 'package:clever_11/presentation/screens/c11_registration/m11_login.dart';
import 'package:clever_11/presentation/screens/c11_registration/m11_registration_screen.dart';
import 'package:clever_11/presentation/screens/home/c11_home.dart';
import 'package:clever_11/presentation/screens/m11_splash.dart';
import 'package:clever_11/presentation/screens/verify_account_screen.dart';
import 'package:clever_11/presentation/screens/my_matches_screen.dart';

class M11_AppRoutes {
  static const String m11_splash = '/m11_splash';
  static const String m11_login = '/m11_login';
  static const String m11_home = '/m11_home';
  static const String m11_registration = '/m11_registration';
  static const String m11_profile = '/m11_profile';
  static const String m11_team_create = '/m11_teamCreate';
  static const String verify_account = '/verify_account';
  static const String my_matches = '/my_matches';

  static Map<String, WidgetBuilder> routes = {
    m11_splash: (context) => const M11_SplashScreen(),
    m11_login: (context) => const M11_LoginTeleportation(),
    m11_home: (context) => const M11_Home(),
    m11_registration: (context) => const M11_RegistrationScreen(),
    m11_team_create: (context) => const M11_CreateTeamScreen(),
    my_matches: (context) => const MyMatchesScreen(),
    m11_profile: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        return M11_ProfileScreen(personalData: {});
      }
      return M11_ProfileScreen(personalData: args as Map<String, dynamic>);
    },
    verify_account: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        return VerifyAccountScreen(email: '', mobile: '');
      }
      final data = args as Map<String, dynamic>;
      return VerifyAccountScreen(
        email: data['email'] ?? '',
        mobile: data['mobile'] ?? '',
        emailVerified: data['emailVerified'] ?? false,
        mobileVerified: data['mobileVerified'] ?? false,
        panVerified: data['panVerified'] ?? false,
        bankVerified: data['bankVerified'] ?? false,
        addressVerified: data['addressVerified'] ?? false,
      );
    },
  };
}
