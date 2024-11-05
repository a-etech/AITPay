import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'package:email_validator/email_validator.dart'; // For validating email
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:flutter_svg/flutter_svg.dart'; // Import for using SVG icons
import '../widgets/bg_container.dart'; // Ensure the correct import path
import 'package:shared_preferences/shared_preferences.dart'; // Import for Shared Preferences

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoadingLogin = false; // Loading state for Login button
  bool _isLoadingGoogle = false; // Loading state for Google Sign-In button
  bool _rememberMe = false; // Remember Me state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignInInstance = GoogleSignIn(); // Renamed variable

  @override
  void initState() {
    super.initState();
    _loadLoginData(); // Load saved login data if any
  }

  // Load saved email and remember me state
  void _loadLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Save email and remember me state
  void _saveLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _rememberMe ? _emailController.text : '');
    await prefs.setBool('rememberMe', _rememberMe);
  }

  // Function to login user
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields.', Colors.red);
      return;
    }

    if (!EmailValidator.validate(email)) {
      _showSnackBar('Invalid email format.', Colors.red);
      return;
    }

    setState(() {
      _isLoadingLogin = true; // Start loading for Login
    });

    try {
      final apiService = ApiService();
      final success = await apiService.loginUser(email, password); // Attempt to login
      if (success) {
        if (_rememberMe) {
          _saveLoginData(); // Save email if Remember Me is checked
        }
        _showSnackBar('Login Successful!', Colors.green);
        // Navigate to your home page or next screen
        Navigator.pushNamed(context, '/home');
      } else {
        _showSnackBar('Invalid email or password.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Login Failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoadingLogin = false; // Stop loading for Login
      });
    }
  }

  // Function for Google Sign-In
  Future<void> _googleSignIn() async {
    setState(() {
      _isLoadingGoogle = true; // Start loading for Google Sign-In
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignInInstance.signIn(); // Use renamed variable
      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoadingGoogle = false; // Stop loading for Google Sign-In
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential); // Sign in with Google credentials
      _showSnackBar('Google Sign-In Successful!', Colors.green);
      // Navigate to your home page or next screen
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      _showSnackBar('Google Sign-In Failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoadingGoogle = false; // Stop loading for Google Sign-In
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.3,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Reduced space
                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15), // Reduced space
                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  const SizedBox(height: 20), // Reduced space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember Me'),
                        ],
                      ),
                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          // Navigate to Forgot Password Page
                          Navigator.pushNamed(context, '/forgot_password'); // Ensure this route is defined
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Reduced space
                  ElevatedButton(
                    onPressed: _isLoadingLogin ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), // Reduced padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.deepPurple[200],
                    ),
                    child: _isLoadingLogin
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text('Login', style: TextStyle(fontSize: 16)), // Reduced font size
                  ),
                  const SizedBox(height: 10), // Reduced space
                  const Text(
                    'or',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Reduced space
                  ElevatedButton.icon(
                    onPressed: _isLoadingGoogle ? null : _googleSignIn, // Call Google sign-in
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), // Reduced padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white, // Google button color
                    ),
                    icon: SvgPicture.asset(
                      'assets/google_icon.svg', // Ensure the correct path to your Google icon
                      height: 34.0,
                    ),
                    label: _isLoadingGoogle
                        ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                        : const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10), // Reduced space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registration'); // Navigate to Register Page
                        },
                        child: const Text('Register here'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApiService {
  final String baseUrl = 'https://aitpay-default-rtdb.firebaseio.com/users.json'; // Replace with your Firebase URL

  // Login user
  Future<bool> loginUser(String email, String password) async {
    final response = await http.get(
      Uri.parse(baseUrl), // Fetch all users
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load users');
    }

    // Parse the response and check for user credentials
    final Map<String, dynamic> users = json.decode(response.body);
    for (var user in users.entries) {
      if (user.value['email'] == email && user.value['password'] == password) {
        return true; // Login successful
      }
    }
    return false; // Login failed
  }
}