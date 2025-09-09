import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

class ErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.instance.logError(
        'Flutter Error: ${details.exception}',
        details.exception,
        details.stack,
      );

      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.instance.logError('Platform Error: $error', error, stack);
      return true;
    };
  }

  static void logAndShowError(
    BuildContext context,
    String message, [
    dynamic error,
  ]) {
    Logger.instance.logError(message, error);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void logInfo(String message) {
    Logger.instance.logInfo(message);
  }

  static void logWarning(String message) {
    Logger.instance.logWarning(message);
  }

  static void logDebug(String message) {
    Logger.instance.logDebug(message);
  }

  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    Logger.instance.logError(message, error, stackTrace);
  }
}
