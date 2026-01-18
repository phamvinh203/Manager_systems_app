import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_type.dart';
import 'package:mobile/utils/snackbar_utils.dart';

class UpdateTaskPage extends StatefulWidget {
  final TaskModel task;

  const UpdateTaskPage({super.key, required this.task});

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskType _selectedType;
  late TaskPriority _selectedPriority;
  DateTime? _startDate;
  DateTime? _dueDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selectedType = widget.task.type;
    _selectedPriority = widget.task.priority;
    _startDate = widget.task.startDate;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'dd/mm/yyyy';
    return Formatters.formatDateVN(date);
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate != null && _startDate != null) {
      if (_dueDate!.isBefore(_startDate!)) {
        SnackBarUtils.showWarning(
          context,
          'Ngày hết hạn phải sau ngày bắt đầu',
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<TaskBloc>().add(
      UpdateTaskEvent(
        taskId: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        type: _selectedType,
        startDate: _startDate,
        dueDate: _dueDate,
      ),
    );

    // Navigate back after successful update
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cập nhật công việc',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Nhóm 1: Tiêu đề + Mô tả =====
              _whiteSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Tiêu đề công việc *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hintText: 'Nhập tên công việc',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên công việc';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Mô tả'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Nhập mô tả chi tiết công việc...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              // ===== Nhóm 2: Phòng ban (readonly) + Loại công việc =====
              _whiteSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Phòng ban'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 20,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.task.department?.name ?? 'Nội bộ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Loại công việc *'),
                    const SizedBox(height: 8),
                    _buildTypeDropdown(),
                  ],
                ),
              ),

              // ===== Nhóm 3: Ưu tiên + Ngày bắt đầu & hết hạn =====
              _whiteSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Mức độ ưu tiên'),
                    const SizedBox(height: 8),
                    _buildPriorityRadioGroup(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Ngày bắt đầu'),
                              const SizedBox(height: 8),
                              _buildDateField(
                                date: _startDate,
                                onTap: () => _selectDate(context, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Ngày hết hạn'),
                              const SizedBox(height: 8),
                              _buildDateField(
                                date: _dueDate,
                                onTap: () => _selectDate(context, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== Nút cập nhật =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    disabledBackgroundColor: const Color(
                      0xFF2F80ED,
                    ).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Cập nhật',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskType>(
          value: _selectedType,
          isExpanded: true,
          items: TaskType.values.map((type) {
            return DropdownMenuItem<TaskType>(
              value: type,
              child: Row(
                children: [
                  Icon(type.icon, size: 20, color: type.color),
                  const SizedBox(width: 8),
                  Text(type.label),
                ],
              ),
            );
          }).toList(),
          onChanged: (type) {
            setState(() {
              _selectedType = type!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPriorityRadioGroup() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TaskPriority.values.map((priority) {
          final isSelected = _selectedPriority == priority;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = priority),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: Colors.black12, width: 0.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  priority.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0B79D0)
                        : const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateField({
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 14,
                color: date == null
                    ? const Color(0xFF9E9E9E)
                    : const Color(0xFF333333),
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Color(0xFF333333),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteSection({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
