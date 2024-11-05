import 'package:AITPay/pages/payment_method_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_paystack/flutter_paystack.dart'; // Import the Paystack plugin

// Import all your pages here
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/homepage.dart';
import 'pages/proceed_to_pay_page.dart';
import 'pages/schedule_of_fee_page.dart';
import 'pages/check_registration_page.dart';
import 'pages/help_support_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // Initialize Paystack with your public test key
  await _initializePaystack();

  // Get shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  bool isLoggedIn = prefs.getBool('loggedIn') ?? false;

  // Run the app
  runApp(AITPayApp(isDarkMode: isDarkMode, isLoggedIn: isLoggedIn));
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Handle Firebase initialization error
    print('Firebase initialization error: $e');
    throw Exception('Failed to initialize Firebase');
  }
}

Future<void> _initializePaystack() async {
  try {
    await PaystackPlugin().initialize(publicKey: 'pk_test_a5536162b17f636c053f6f15495f4b56548feafe');
  } catch (e) {
    // Handle Paystack initialization error
    print('Paystack initialization error: $e');
    throw Exception('Failed to initialize Paystack');
  }
}

class AITPayApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;

  const AITPayApp({Key? key, required this.isDarkMode, required this.isLoggedIn}) : super(key: key);

  @override
  _AITPayAppState createState() => _AITPayAppState();
}

class _AITPayAppState extends State<AITPayApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AITPay',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: widget.isLoggedIn ? '/home' : '/welcome',
      routes: _buildRoutes(),
      onGenerateRoute: _generateRoute,
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/welcome': (context) => WelcomePage(toggleTheme: _toggleTheme),
      '/login': (context) => const LoginPage(),
      '/registration': (context) => const RegistrationPage(),
      '/home': (context) => HomePage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      '/proceedToPay': (context) => const ProceedToPayPage(),
      '/scheduleOfFee': (context) => const ScheduleOfFeePage(),
      '/checkRegistration': (context) => const CheckRegistrationPage(),
      '/helpSupport': (context) => HelpSupportPage(),
      '/forgot_password': (context) => const ForgotPasswordPage(),
    };
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/payment_page':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PaymentPage(
            studentID: args['studentID'],
            level: args['level'],
            semester: args['semester'],
            amountToPay: args['amountToPay'],
          ),
        );
      default:
        return null; // Return null for unhandled routes
    }
  }
}
