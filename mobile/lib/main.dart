import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await Hive.initFlutter();
  
  await Hive.openBox('user_cache');
  await Hive.openBox('wallet_cache');
  await Hive.openBox('transactions_cache');
  await Hive.openBox('settings_cache');
  
  runApp(
    const ProviderScope(
      child: JufaAppWrapper(),
    ),
  );
}

class JufaAppWrapper extends ConsumerWidget {
  const JufaAppWrapper({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return JufaApp(routerConfig: router);
  }
}
