import 'package:flutter/material.dart';

class ManagerTaskCardActions extends StatelessWidget {
  final VoidCallback? onTap;

  const ManagerTaskCardActions({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.more_horiz,
          size: 24,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}
