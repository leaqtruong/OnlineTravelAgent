import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:online_travel_agent/core/theme/app_theme.dart';
import 'package:online_travel_agent/providers/travel_provider.dart';
import 'package:online_travel_agent/screens/main/main_screen.dart';
import 'package:online_travel_agent/screens/welcome/welcome_screen.dart';

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
        home: const WelcomeScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}
