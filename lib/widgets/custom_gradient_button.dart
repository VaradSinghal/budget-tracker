import 'package:flutter/material.dart';


class CustomGradientButton extends StatefulWidget {
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
  _CustomGradientButtonState createState() => _CustomGradientButtonState();
}

class _CustomGradientButtonState extends State<CustomGradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ScaleTransition(
        scale: widget.scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
            widget.controller.forward();
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
            widget.controller.reverse();
            widget.onPressed();
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
            widget.controller.reverse();
          },
          child: AnimatedOpacity(
            opacity: _isPressed ? 0.7 : 1.0,
            duration: const Duration(milliseconds: 100),
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
                    widget.text,
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
      ),
    );
  }
}