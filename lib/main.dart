import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/workout_service.dart';
import 'core/services/nutrition_service.dart';
import 'core/services/trainer_service.dart';
import 'ui/auth/login_screen.dart';
import 'ui/client/client_main_screen.dart';
import 'ui/trainer/trainer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely (falls back to local/demo mode if config is not yet supplied)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e (Running in offline demo mode)');
  }

  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WorkoutService()),
        ChangeNotifierProvider(create: (_) => NutritionService()),
        ChangeNotifierProvider(create: (_) => TrainerService()),
      ],
      child: MaterialApp(
        title: 'Pulse Gym App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGatekeeper(),
      ),
    );
  }
}

class AuthGatekeeper extends StatelessWidget {
  const AuthGatekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (auth.isTrainer) {
      return const TrainerMainScreen();
    }

    return const ClientMainScreen();
  }
}
