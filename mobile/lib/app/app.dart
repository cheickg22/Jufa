import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_theme.dart';
import '../core/theme/theme_provider.dart';

class JufaApp extends ConsumerWidget {
  final RouterConfig<Object> routerConfig;
  
  const JufaApp({super.key, required this.routerConfig});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'JUFA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: routerConfig,
    );
  }
}
