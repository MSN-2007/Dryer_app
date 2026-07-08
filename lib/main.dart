import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/state/library_provider.dart';
import 'presentation/state/dryer_provider.dart';
import 'presentation/state/settings_provider.dart';
import 'presentation/pages/main_navigation_holder.dart';
import 'presentation/pages/error/custom_error_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register custom error handler to shield farmers from red/grey crash screens
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      title: 'Smart Dryer Exception',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: CustomErrorPage(errorDetails: details),
    );
  };
  
  runApp(const SmartDryerApp());
}

class SmartDryerApp extends StatelessWidget {
  const SmartDryerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => DryerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Dryer Automation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Dynamically follow system dark/light preferences
        home: const MainNavigationHolder(),
      ),
    );
  }
}
