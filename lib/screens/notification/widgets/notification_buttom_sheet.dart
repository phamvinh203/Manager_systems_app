import 'package:flutter/material.dart';

class NotificationBottomSheet extends StatelessWidget {
  final Widget Function(ScrollController controller) builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const NotificationBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize = 0.75,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: builder(controller),
        );
      },
    );
  }
}