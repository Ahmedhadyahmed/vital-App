import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glassy_input_field.dart';
import '../widgets/gradient_button.dart';
import 'number confirmation.dart';
import 'register_screen.dart';
import 'home_page.dart';
 // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;

  void _login() {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username != 'admin') {
      setState(() {
        _usernameError = 'Non-existing username';
      });
      return;
    }

    if (password != 'admin') {
      setState(() {
        _passwordError = 'Password is incorrect';
      });
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A6E6E),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Welcome back we missed you too much',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_usernameError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(_usernameError!, style: const TextStyle(color: Colors.red)),
                            ),
                          GlassyInputField(
                            icon: Icons.person,
                            hint: 'Username',
                            controller: _usernameController,
                          ),
                          const SizedBox(height: 20),
                          if (_passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(_passwordError!, style: const TextStyle(color: Colors.red)),
                            ),
                          GlassyInputField(
                            icon: Icons.key,
                            hint: 'Password',
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to ForgotPasswordScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GradientButton(text: 'Login', onPressed: _login),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Colors.white38)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text('Or continue with', style: TextStyle(color: Colors.white54)),
                              ),
                              Expanded(child: Divider(color: Colors.white38)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
                              Icon(Icons.apple, size: 28, color: Colors.white),
                              Icon(Icons.facebook, size: 28, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                },
                                child: const Text(
                                  'Register Now',
                                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}