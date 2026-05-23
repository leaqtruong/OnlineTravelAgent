import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/travel_provider.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const OnlineTravelAgentApp());
}

class OnlineTravelAgentApp extends StatefulWidget {
  const OnlineTravelAgentApp({super.key});

  @override
  State<OnlineTravelAgentApp> createState() => _OnlineTravelAgentAppState();
}

class _OnlineTravelAgentAppState extends State<OnlineTravelAgentApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use addPostFrameCallback to ensure the first frame is rendered
    // before starting heavy image pre-caching, avoiding blocking the main thread on startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safePrecache("assets/images/dalat_image.jpg");
      _safePrecache("assets/images/phuquoc_image.jpg");
      _safePrecache("assets/images/hoian_image.webp");
    });
  }

  void _safePrecache(String assetPath) {
    if (!mounted) return;
    precacheImage(
      AssetImage(assetPath),
      context,
      onError: (exception, stackTrace) {
        debugPrint("Error pre-caching image $assetPath: $exception");
      },
    ).catchError((error) {
      debugPrint("Failed to precache $assetPath: $error");
    });
  }

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
