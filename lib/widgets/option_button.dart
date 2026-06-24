import 'package:flutter/material.dart';

class OptionButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _controller.forward().then((_) {
              _controller.reverse();
            });
            widget.onTap();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
            backgroundColor: const Color(0xFFFFD84D),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            shadowColor: const Color(0xFFFFD84D).withAlpha(100),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}