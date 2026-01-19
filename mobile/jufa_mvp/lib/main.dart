import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/bloc_observer.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/l10n/app_localizations.dart';
// import 'core/services/firebase_simple_service.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration système
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase temporairement désactivé
  // try {
  //   // Initialisation Firebase avec configuration
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   print('🔥 Firebase initialisé avec succès');
  //   
  //   // Initialisation des notifications Firebase (version simplifiée)
  //   await FirebaseSimpleService.initialize();
  //   print('🔔 Service de notifications initialisé');
  // } catch (e) {
  //   print('❌ Erreur initialisation Firebase: $e');
  // }

  // Initialisation Hive
  await Hive.initFlutter();

  // Configuration de l'injection de dépendances
  await configureDependencies();

  // Configuration du BLoC observer pour le debugging
  Bloc.observer = AppBlocObserver();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const JufaApp(),
    ),
  );
}

class JufaApp extends StatelessWidget {
  const JufaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('en'), // Anglais
          ],
        );
      },
    );
  }
}
