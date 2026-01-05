import 'package:equatable/equatable.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/models/pagination_model.dart';

enum EmployeeStatus {
  initial,
  loading,
  loaded,
  error,
}

class EmployeeState extends Equatable {
  // screen status
  final EmployeeStatus status;
  //data
  final List<Employee> employees;
  final Pagination? pagination;

  /// Messages
  final String? errorMessage;
  final String? successMessage;

  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.employees = const [],
    this.pagination,
    this.successMessage,
    this.errorMessage,
  });

  factory EmployeeState.initial() {
    return const EmployeeState();
  }

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<Employee>? employees,
    Pagination? pagination,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPagination = false,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      pagination:
          clearPagination ? null : (pagination ?? this.pagination),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  // === Helper Getters ===
  
  bool get isInitial => status == EmployeeStatus.initial;
  bool get isLoading => status == EmployeeStatus.loading;
  bool get isLoaded => status == EmployeeStatus.loaded;
  bool get isError => status == EmployeeStatus.error;
  
  bool get isEmpty => employees.isEmpty;
  bool get isNotEmpty => employees.isNotEmpty;
  
  int get totalEmployees => employees.length;

  @override
  List<Object?> get props => [
        status,
        employees,
        pagination,
        errorMessage,
        successMessage,
      ];
}