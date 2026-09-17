import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/core/routes/route_generator.dart';
import 'package:contacting_app/core/theme/app_theme.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/firebase_options.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CallViewModel>.value(value: getIt<CallViewModel>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: RouteGenerator.getRoutes,
      initialRoute: AppRoutes.splash,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
