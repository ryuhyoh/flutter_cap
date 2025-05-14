import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  final double currentWidth;
  final double currentHeight;
  final double borderRadius;
  final Widget contentChild; // 카드의 실제 내용 (GestureDetector, Stack 등)
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;

  const CardShell({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
    required this.borderRadius,
    required this.contentChild,
    required this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: currentWidth,
      height: currentHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            boxShadow ?? // 기본 그림자 또는 null 허용
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: contentChild,
      ),
    );
  }
}
