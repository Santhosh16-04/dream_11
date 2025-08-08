import 'package:clever_11/cubit/team/team_event.dart';
import 'package:clever_11/firebase_options.dart';
import 'package:clever_11/presentation/notification/firebaseMsg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'cubit/team/team_bloc.dart';
import 'presentation/blocs/my_contests/my_contests_bloc.dart';
import 'presentation/blocs/my_contests/my_contests_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zones once
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM
  await Firebasemsg().initFCM();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              TeamBloc()..add(LoadTeams()), // <-- Load teams at startup
        ),
        BlocProvider(
          create: (_) => MyContestsBloc()
            ..add(LoadMyContests()), // <-- Load contests at startup
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: M11_AppRoutes.m11_splash,
      routes: M11_AppRoutes.routes,
    );
  }
}
