import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaming_library/gaming_library.dart';

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaming Library Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Simulated user ID — in your real app this comes from your auth system
  static const String _demoUserId = '00000000-0000-0000-0000-000000000001';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, color: colors.primary, size: 64),
            const SizedBox(height: 24),
            Text(
              'Main App',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to open the Games Hub',
              style: TextStyle(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => GamingLibrary.launch(context, userId: _demoUserId),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Open Game Arcade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
