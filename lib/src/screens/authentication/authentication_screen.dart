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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  AuthFormType _authFormType = AuthFormType.signIn;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _auth() async {
    if (_formKey.currentState!.validate()) {
      // If it's a signUp form, check if the passwords match
      if (_authFormType == AuthFormType.signUp &&
          _passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = "Passwords do not match";
        });
        return;
      }

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
        // Navigate to AdminHome if a user is successfully signed in or signed up
        if (userCredential.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminHome()),
          );
        } else {
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
      _authFormType = _authFormType == AuthFormType.signIn
          ? AuthFormType.signUp
          : AuthFormType.signIn;
      _errorMessage = '';
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignInForm = _authFormType == AuthFormType.signIn;
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignInForm ? 'Login' : 'Register'),
        backgroundColor: Color(0xFF34559C),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 100, errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error); // Fallback to an icon if the image fails to load
              }), SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              // Confirm Password field for SignUp form
              if (_authFormType == AuthFormType.signUp)
                Column(
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _auth,
                child: Text(isSignInForm ? 'Login' : 'Register'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF34559C), minimumSize: Size(double.infinity, 50), // text color
                ),
              ),
              TextButton(
                onPressed: _toggleFormType,
                child: Text(isSignInForm
                    ? 'Don\'t have an account? Register'
                    : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
