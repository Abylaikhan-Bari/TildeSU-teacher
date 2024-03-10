import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';
import 'package:tildesu_teacher/src/screens/common/admin_home.dart';

enum AuthFormType { signIn, signUp }

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  AuthFormType _authFormType = AuthFormType.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _auth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (_authFormType == AuthFormType.signIn) {
      User? user = await _authService.signIn(email, password);
      if (user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminHome()));
      } else {
        // Handle login error
      }
    } else {
      User? user = await _authService.signUp(email, password);
      if (user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminHome()));
      } else {
        // Handle registration error
      }
    }
  }

  void _toggleFormType() {
    setState(() {
      _authFormType = _authFormType == AuthFormType.signIn ? AuthFormType.signUp : AuthFormType.signIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignInForm = _authFormType == AuthFormType.signIn;
    return Scaffold(
      appBar: AppBar(title: Text(isSignInForm ? 'Sign In' : 'Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _auth,
              child: Text(isSignInForm ? 'Sign In' : 'Sign Up'),
            ),
            TextButton(
              onPressed: _toggleFormType,
              child: Text(isSignInForm ? 'Need an account? Sign up' : 'Have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
