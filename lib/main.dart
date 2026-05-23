import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/travel_provider.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnlineTravelAgentApp());
}

class OnlineTravelAgentApp extends StatelessWidget {
  const OnlineTravelAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TravelProvider()),
      ],
      child: MaterialApp(
        title: 'Online Travel Agent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}
