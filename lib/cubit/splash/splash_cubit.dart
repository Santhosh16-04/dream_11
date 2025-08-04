import 'package:clever_11/cubit/splash/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.loading);

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loginStatus = prefs.getString("loginStatus") ?? "";

    await Future.delayed(const Duration(seconds: 2));

    if (loginStatus == "success") {
      emit(SplashState.home);
    } else {
      emit(SplashState.login);
    }
  }
}
