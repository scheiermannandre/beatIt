import 'package:beat_it/lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting();

  // Re-initialize Hive after deletion
  await Hive.initFlutter();
  Hive
    ..registerAdapter(ChallengeDtoAdapter())
    ..registerAdapter(DayDtoAdapter())
    ..registerAdapter(DayStatusDtoAdapter());

  // final box = await Hive.openBox('challenges');
  // await box.deleteFromDisk();
  // await box.close();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
