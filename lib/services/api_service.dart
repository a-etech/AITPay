import 'dart:convert';
import 'package:crypto/crypto.dart'; // Import the crypto package
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ApiService {
  final String baseUrl = 'https://aitpay-default-rtdb.firebaseio.com/'; // Firebase URL

  // Function to hash the password
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Create SHA-256 hash
    return digest.toString(); // Return the hashed password
  }

  // Fetch payments from the server
  Future<List<dynamic>> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payments'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['payments'];
      } else {
        throw Exception('Failed to load payments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  // Register a new user with studentId, email, and password
  Future<bool> registerUser(String studentId, String email, String password) async {
    try {
      final hashedPassword = hashPassword(password); // Hash the password
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'email': email,
          'password': hashedPassword, // Use the hashed password
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to register user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login an existing user with email and password
  Future<bool> loginUser(String email, String password) async {
    try {
      // Sign in the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password, // Use the plain password
      );

      if (userCredential.user != null) {
        // Fetch user details from the database
        final userDetails = await getUserDetails(email);
        if (userDetails != null) {
          print('User details: $userDetails');
          return true; // Login successful and user exists in database
        } else {
          print('User not found in the database.');
          return false; // User not found in the database
        }
      }
    } catch (e) {
      // Handle specific exceptions for better error handling
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            print('No user found for that email.');
            break;
          case 'wrong-password':
            print('Wrong password provided for that user.');
            break;
          default:
            print('Login failed: ${e.message}');
        }
      } else {
        print('Login failed: ${e.toString()}');
      }
    }
    return false; // Login failed
  }


  // Fetch user details (like studentId, level, semester) after login
  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?orderBy="email"&equalTo="${email.toLowerCase()}"'),
      );

      if (response.statusCode == 200) {
        final users = json.decode(response.body);
        if (users.isNotEmpty) {
          return users.values.first; // Return the first user's details
        }
      } else {
        throw Exception('Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch user details: $e');
    }

    return null; // Return null if the user is not found or an error occurs
  }

  // Password reset method
  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true; // Return true if the email was sent successfully
    } catch (e) {
      // Handle error (optional: log the error)
      return false; // Return false if there was an error
    }
  }
}
