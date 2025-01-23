import 'package:logging/logging.dart';

class AppLogger {
  static final _logger = Logger('BeatIt');

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.time}: ${record.level.name}: ${record.message}');
      if (record.error != null) print('Error: ${record.error}');
      if (record.stackTrace != null) print('Stack: ${record.stackTrace}');
    });
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}
