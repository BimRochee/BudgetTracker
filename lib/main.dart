import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/budget_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling and logging
  ErrorHandler.initialize();
  ErrorHandler.logInfo('App started');

  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = BudgetProvider();
        provider.loadAllData(); // Load all data on app start
        return provider;
      },
      child: MaterialApp(
        title: 'BudgetTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
