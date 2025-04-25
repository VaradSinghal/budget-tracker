import 'package:flutter/material.dart';


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
  bool _isObscured = true;

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
    _isObscured = widget.obscureText;
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
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF00E7FF).withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      )
                    : null,
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
              obscureText: widget.obscureText && _isObscured,
              validator: widget.validator,
              onSaved: widget.onSaved,
            ),
          );
        },
      ),
    );
  }
}
