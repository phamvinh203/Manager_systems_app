import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: validator,
      initialValue: selectedDate,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showDatePicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.hasError ? Colors.red : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : 'Chọn ngày',
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? now;
    final effectiveLastDate = lastDate ?? DateTime(now.year + 1);

    // Đảm bảo initialDate nằm trong khoảng [firstDate, lastDate]
    DateTime effectiveInitialDate = selectedDate ?? effectiveFirstDate;
    if (effectiveInitialDate.isBefore(effectiveFirstDate)) {
      effectiveInitialDate = effectiveFirstDate;
    }
    if (effectiveInitialDate.isAfter(effectiveLastDate)) {
      effectiveInitialDate = effectiveLastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
