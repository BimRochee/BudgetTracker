import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Logger {
  static const String _logFileName = 'budget_tracker_logs.txt';
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();

  Logger._();

  Future<void> logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] ERROR: $message';
    final errorMessage = error != null ? '\nError: $error' : '';
    final stackMessage = stackTrace != null ? '\nStack Trace: $stackTrace' : '';

    await _writeToFile('$logMessage$errorMessage$stackMessage\n');
  }

  Future<void> logInfo(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] INFO: $message\n';
    await _writeToFile(logMessage);
  }

  Future<void> logWarning(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] WARNING: $message\n';
    await _writeToFile(logMessage);
  }

  Future<void> logDebug(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] DEBUG: $message\n';
    await _writeToFile(logMessage);
  }

  Future<void> _writeToFile(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      await file.writeAsString(message, mode: FileMode.append);
    } catch (e) {
      // Silently fail if file writing fails
      // This prevents infinite loops if logging itself fails
    }
  }

  Future<String> getLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No logs found.';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail if clearing logs fails
    }
  }
}
