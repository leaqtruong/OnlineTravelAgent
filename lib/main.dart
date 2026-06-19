import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/welcome/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/partner/partner_dashboard_screen.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OnlineTravelAgentApp()));
}

class OnlineTravelAgentApp extends ConsumerWidget {
  const OnlineTravelAgentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate bootstrap sync (profile + documents from bootstrap data)
    ref.watch(bootstrapSyncProvider);

    return MaterialApp(
      title: 'Online Travel Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/partner-dashboard': (context) => const PartnerDashboardScreen(),
      },
    );
  }
}
