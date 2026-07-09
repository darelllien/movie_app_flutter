import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountData {
  static const String _baseUrl = 'YOUR_BACKEND_API_URL_HERE';

  static Future<void> initializeAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_name')) {
      await prefs.setString('user_name', 'admin');
      await prefs.setString('user_email', 'admin123@gmail.com');
      await prefs.setString('user_password', 'admin123');
      await prefs.setString('user_image', '');
    }
  }

  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/local'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        await prefs.setBool('is_logged_in', true);
        if (user != null) {
          await prefs.setString(
            'user_name',
            user['username'] ?? user['name'] ?? 'User',
          );
          await prefs.setString('user_email', user['email'] ?? email);
        }
        return true;
      }
      return false;
    } catch (e) {
      final String localEmail =
          prefs.getString('user_email') ?? 'admin123@gmail.com';
      final String localPassword =
          prefs.getString('user_password') ?? 'admin123';

      if (email == localEmail && password == localPassword) {
        await prefs.setBool('is_logged_in', true);
        return true;
      }
      return false;
    }
  }

  static Future<bool> loginWithGoogleFirebase() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>['email']);

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        return false;
      }

      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', user.displayName ?? 'Google User');
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_image', user.photoURL ?? '');

      developer.log('Google Login Success', name: 'GoogleAuth');
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuthException: ${e.code}',
        error: e.message,
        name: 'GoogleAuth',
      );
      return false;
    } catch (e, s) {
      developer.log(
        'Google Login Error',
        error: e,
        stackTrace: s,
        name: 'GoogleAuth',
      );
      return false;
    }
  }

  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/local/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': name,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
      return true;
    }
  }

  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localName = prefs.getString('user_name');
    final String? localEmail = prefs.getString('user_email');
    final String? localImagePath = prefs.getString('user_image');

    if (localName != null && localEmail != null) {
      return {
        'name': localName,
        'email': localEmail,
        'image': localImagePath ?? '',
      };
    }
    return null;
  }

  static Future<void> updateUser(String newName, String? newImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    if (newImagePath != null) {
      await prefs.setString('user_image', newImagePath);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', false);

    await FirebaseAuth.instance.signOut();

    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }
}
