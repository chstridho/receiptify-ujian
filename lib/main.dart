import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receiptify/screens/sign_in_page.dart';
import 'package:receiptify/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_colors.dart';
import 'screens/home_page.dart';
import 'services/meal_api.dart';
import 'managers/favorites_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vdvlwprucvmwnnuhbyrs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkdmx3cHJ1Y3Ztd25udWhieXJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3MTU0MTUsImV4cCI6MjA2MjI5MTQxNX0.m244YtSz-xoC79hK1XZzdyipaaReADN2KluUPUKn7tQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MealApi()),
        ChangeNotifierProvider(create: (_) => FavoritesManager()),
      ],
      child: const ReceiptifyApp(),
    ),
  );
}

class ReceiptifyApp extends StatelessWidget {
  const ReceiptifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receiptify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashToSignIn(),
      
      routes: {
        '/homepage': (context) => const HomePage(),
        // routes lainnya
      },
    );
  }
}

class SplashToSignIn extends StatefulWidget {
  const SplashToSignIn({super.key});

  @override
  State<SplashToSignIn> createState() => _SplashToSignInState();
}

class _SplashToSignInState extends State<SplashToSignIn> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _goToSignIn);
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
