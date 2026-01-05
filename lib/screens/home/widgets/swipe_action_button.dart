import 'package:flutter/material.dart';

class SwipeActionButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback? onSwipeComplete;

  const SwipeActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.buttonColor,
    required this.textColor,
    this.icon = Icons.arrow_forward_rounded,
    this.onSwipeComplete,
  });

  // Factory constructor cho Check In
  factory SwipeActionButton.checkIn({VoidCallback? onSwipeComplete}) {
    return SwipeActionButton(
      text: 'Swipe to Check In',
      backgroundColor: const Color(0xFFDCFCE7),
      buttonColor: const Color(0xFF22C55E),
      textColor: const Color(0xFF22C55E),
      onSwipeComplete: onSwipeComplete,
    );
  }

  // Factory constructor cho Check Out
  factory SwipeActionButton.checkOut({VoidCallback? onSwipeComplete}) {
    return SwipeActionButton(
      text: 'Swipe to Check Out',
      backgroundColor: const Color(0xFFFEE2E2),
      buttonColor: const Color(0xFFEF4444),
      textColor: const Color(0xFFEF4444),
      onSwipeComplete: onSwipeComplete,
    );
  }

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _maxDrag = 0;
  bool _isCompleted = false;

  late AnimationController _animationController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.addListener(() {
      setState(() {
        _dragPosition = _resetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _maxDrag = constraints.maxWidth - 56;

          return Stack(
            children: [
              // Text ở giữa
              Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              // Draggable button
              Positioned(
                left: 4 + _dragPosition,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      _dragPosition = _dragPosition.clamp(0.0, _maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isCompleted) return;

                    if (_dragPosition >= _maxDrag * 0.7) {
                      // Swipe hoàn thành
                      setState(() {
                        _isCompleted = true;
                        _dragPosition = _maxDrag;
                      });
                      widget.onSwipeComplete?.call();

                      // Reset sau 500ms
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() => _isCompleted = false);
                          _resetPosition();
                        }
                      });
                    } else {
                      // Reset vị trí
                      _resetPosition();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 48,
                    decoration: BoxDecoration(
                      color: widget.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.buttonColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isCompleted ? Icons.check_rounded : widget.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
