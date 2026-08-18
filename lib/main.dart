import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WmsApp());
}

class WmsApp extends StatelessWidget {
  const WmsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS Forklift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.orange[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.orange[800]!,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

