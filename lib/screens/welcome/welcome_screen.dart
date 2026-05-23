import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> images = [
    "assets/images/dalat_image.jpg",
    "assets/images/phuquoc_image.jpg",
    "assets/images/hoian_image.webp"
  ];
  int currentImageIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          currentImageIndex = (currentImageIndex + 1) % images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background while loading images
      body: Stack(
        children: [
          // 1. Background Image Layer
          Positioned.fill(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: Image.asset(
                  images[currentImageIndex],
                  key: ValueKey<int>(currentImageIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("Error loading image: $error");
                    return Container(color: Colors.blueGrey);
                  },
                ),
              ),
          ),

          // 2. Gradient Overlay Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. UI Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  const Center(
                    child: Text(
                      "Vietnam",
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Tận hưởng",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const Text(
                    "Kỳ nghỉ",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Trong mơ",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button at the bottom
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Khám phá",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Padding from bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
