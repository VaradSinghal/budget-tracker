import 'package:flutter/material.dart';


class CustomNavigationLink extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomNavigationLink({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CustomNavigationLinkState createState() => _CustomNavigationLinkState();
}

class _CustomNavigationLinkState extends State<CustomNavigationLink> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: TextButton(
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Color(0xFF00E7FF), 
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}