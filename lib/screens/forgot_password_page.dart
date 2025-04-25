import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:budget_tracker/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String? _message;
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

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _authService.resetPassword(_email);
        setState(() {
          _message = 'Password reset email sent. Check your inbox.';
        });
      } catch (e) {
        setState(() {
          _message = e.toString();
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
                          'Reset your password',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFFE5E7EB).withOpacity(0.7),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        const SizedBox(height: 40),
                        _buildFormCard(context),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2526).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              color: const Color(0xFF1C2526).withOpacity(0.4),
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
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('sent')
                              ? const Color(0xFF00E7FF) 
                              : const Color(0xFF00E7FF), 
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  CustomGradientButton(
                    text: 'Send Reset Email',
                    onPressed: _resetPassword,
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

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.validator,
    required this.onSaved,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _controller.repeat(reverse: true);
        } else {
          _controller.stop();
          _controller.value = 0;
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E7FF).withOpacity(0.3 * _glowAnimation.value),
                  const Color(0xFF4B5EAA).withOpacity(0.1 * _glowAnimation.value),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF00E7FF).withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(widget.icon, color: const Color(0xFFE5E7EB).withOpacity(0.7)),
                labelStyle: const TextStyle(
                    color: Color(0xFFE5E7EB), fontFamily: 'Roboto'),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF4B5EAA).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00E7FF), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00E7FF)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00E7FF), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF1C2526).withOpacity(0.5),
              ),
              style: const TextStyle(color: Color(0xFFE5E7EB), fontFamily: 'Roboto'),
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              validator: widget.validator,
              onSaved: widget.onSaved,
            ),
          );
        },
      ),
    );
  }
}

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AnimationController controller;
  final Animation<double> scaleAnimation;

  const CustomGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.controller,
    required this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => controller.forward(),
          onTapUp: (_) {
            controller.reverse();
            onPressed();
          },
          onTapCancel: () => controller.reverse(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B5EAA), Color(0xFF00E7FF)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748), 
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}