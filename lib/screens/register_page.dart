import 'dart:ui';
import 'package:budget_tracker/screens/home_page.dart';
import 'package:budget_tracker/widgets/custom_gradient_button.dart';
import 'package:budget_tracker/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _errorMessage;
  final AuthService _authService = AuthService();

  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  late AnimationController _gradientController;
  late Animation<Color?> _gradientColor1;
  late Animation<Color?> _gradientColor2;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoController.forward();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _gradientColor1 = ColorTween(
      begin: const Color(0xFF1C2526), 
      end: const Color(0xFF4B5EAA), 
    ).animate(_gradientController);
    _gradientColor2 = ColorTween(
      begin: const Color(0xFF4B5EAA), 
      end: const Color(0xFF1C2526), 
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _authService.register(_email, _password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomePage()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradientColor1.value!, _gradientColor2.value!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..scale(_logoScaleAnimation.value)
                                ..rotateZ(_logoRotateAnimation.value),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    size: 60,
                                    color: Color(0xFFE5E7EB), 
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Budget Tracker',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: const Color(0xFFE5E7EB),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create your account',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFFE5E7EB).withOpacity(0.7),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        const SizedBox(height: 40),
                        _buildFormCard(context),
                        const SizedBox(height: 24),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          color: const Color(0xFF00E7FF).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F30).withOpacity(0.3), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2F30).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4B5EAA).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFF00E7FF),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  CustomGradientButton(
                    text: 'Register',
                    onPressed: _register,
                    controller: _buttonController,
                    scaleAnimation: _buttonScaleAnimation,
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
