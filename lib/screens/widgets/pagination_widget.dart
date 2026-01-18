import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous <
          if (currentPage > 1)
            _buildArrowButton(
              icon: Icons.chevron_left,
              onTap: () => onPageChanged(currentPage - 1),
            ),

          const SizedBox(width: 8),

          // Current page number
          _buildPageIndicator(currentPage),

          const SizedBox(width: 8),

          // Next >
          if (currentPage < totalPages)
            _buildArrowButton(
              icon: Icons.chevron_right,
              onTap: () => onPageChanged(currentPage + 1),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int page) {
    return Container(
      width: 40,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$page',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }
}
