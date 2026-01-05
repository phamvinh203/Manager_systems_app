import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          _buildArrowButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 1,
            onPressed: () => onPageChanged(currentPage - 1),
          ),

          const SizedBox(width: 8),

          // Page numbers
          ..._buildPageNumbers(),

          const SizedBox(width: 8),

          // Next button
          _buildArrowButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onPressed: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> widgets = [];
    final List<dynamic> pageItems = _getPageItems();

    for (int i = 0; i < pageItems.length; i++) {
      final item = pageItems[i];

      if (item == '...') {
        widgets.add(_buildEllipsis());
      } else {
        widgets.add(_buildPageNumberButton(item as int));
      }
    }

    return widgets;
  }
  
  List<dynamic> _getPageItems() {
    final List<dynamic> items = [];

    if (totalPages <= 7) {
      // Hiển thị tất cả nếu ít hơn 7 trang
      for (int i = 1; i <= totalPages; i++) {
        items.add(i);
      }
    } else {
      // Luôn hiển thị trang đầu
      items.add(1);

      if (currentPage <= 3) {
        // Gần đầu: 1 2 3 4 ... 9 10
        items.add(2);
        items.add(3);
        items.add(4);
        items.add('...');
        items.add(totalPages - 1);
        items.add(totalPages);
      } else if (currentPage >= totalPages - 2) {
        // Gần cuối: 1 2 ... 7 8 9 10
        items.add(2);
        items.add('...');
        items.add(totalPages - 3);
        items.add(totalPages - 2);
        items.add(totalPages - 1);
        items.add(totalPages);
      } else {
        // Ở giữa: 1 ... 4 5 6 ... 10
        items.add('...');
        items.add(currentPage - 1);
        items.add(currentPage);
        items.add(currentPage + 1);
        items.add('...');
        items.add(totalPages);
      }
    }

    return items;
  }

  Widget _buildPageNumberButton(int pageNumber) {
    final isActive = pageNumber == currentPage;

    return GestureDetector(
      onTap: () => onPageChanged(pageNumber),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}