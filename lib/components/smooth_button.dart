import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class SmoothButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool isOutlined;
  final Color? outlineColor;

  const SmoothButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.isOutlined = false,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: SmoothRectangleBorder(
            smoothness: 0.6,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutlined ? Colors.transparent : Colors.white,
            foregroundColor: isOutlined ? Colors.white : Colors.black,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            elevation: isOutlined ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isOutlined
                  ? BorderSide(color: outlineColor ?? Colors.white, width: 2)
                  : BorderSide.none,
            ),
          ),
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }
}
