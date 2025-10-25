import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/artist/artist_home_screen.dart';
import 'screens/studio/studio_home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/booking_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YusicApp());
}

class YusicApp extends StatelessWidget {
  const YusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FolderProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Yusic - Music Studio Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/artist-home': (context) => const ArtistHomeScreen(),
          '/studio-home': (context) => const StudioHomeScreen(),
        },
      ),
    );
  }
}
