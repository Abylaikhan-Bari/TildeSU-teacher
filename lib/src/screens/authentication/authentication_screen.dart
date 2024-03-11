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
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  AuthFormType _authFormType = AuthFormType.signIn;
  String _errorMessage = ''; // To display error messages

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _auth() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential;
        if (_authFormType == AuthFormType.signIn) {
          userCredential = (await _authService.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )) as UserCredential;
        } else {
          userCredential = (await _authService.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )) as UserCredential;
        }
        if (userCredential.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminHome()),
          );
        } else {
          // If userCredential.user is null, handle it accordingly
          setState(() {
            _errorMessage = 'Authentication failed, please try again.';
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message ?? 'An unknown error occurred';
        });
      }
    }
  }

  void _toggleFormType() {
    setState(() {
      _errorMessage = ''; // Clear error message when switching form type
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
    child: Form(
    key: _formKey, // Use the form key
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TextFormField(
    controller: _emailController,
    decoration: InputDecoration(labelText: 'Email'),
    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your email' : null,
    ),
    TextFormField(
    controller: _passwordController,
    decoration: InputDecoration(labelText: 'Password'),
    obscureText: true,
    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
    ),
    SizedBox(height: 24),
    if (_errorMessage.isNotEmpty) // Display error message if not empty
    Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 14)),
    ElevatedButton(
    onPressed: _auth,
    child: Text(isSignInForm ? 'Sign In' : 'Sign Up'),
    ),
    TextButton(
    onPressed: _toggleFormType,
    child: Text(isSignInForm ? 'Need an account? Sign up' : 'Have an account? Sign in')
    ),
    ],
    ),
    ),
    ),
    );
  }
}
