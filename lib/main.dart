import 'package:beat_it/lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// TODO(dev): Error handling

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting();


  //// Delete everything in Hive  
  // await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk('challenges');
  // await Hive.deleteBoxFromDisk('archived_challenges');

  // Re-initialize Hive after deletion
  await Hive.initFlutter();
  Hive
    ..registerAdapter(ChallengeDtoAdapter())
    ..registerAdapter(DayDtoAdapter())
    ..registerAdapter(DayStatusDtoAdapter());

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
    );
  }
}


// import 'package:flutter/material.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   static const String _title = 'Flutter Code Sample';

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: _title,
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('BottomNavigationBar Sample'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showModalBottomSheet(
//               backgroundColor: Colors.black45,
//               context: context,
//               builder: (_) => ScaffoldMessenger(
//                 child: Builder(
//                   builder: (context) {
//                     return Scaffold(
//                       backgroundColor: Colors.transparent,
//                       body: Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Test'),
//                                 behavior: SnackBarBehavior.floating,
//                               ),
//                             );
//                           },
//                           child: const Text('Show snackbar'),
//                         ),
//                       ),
//                     );
//                   }
//                 ),
//               ),
//             );
//           },
//           child: const Text('Open bottom sheet'),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.business),
//             label: 'Business',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.school),
//             label: 'School',
//           ),
//         ],
//       ),
//     );
//   }
// }