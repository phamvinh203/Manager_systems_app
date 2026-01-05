import 'package:equatable/equatable.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/models/pagination_model.dart';

/// Trạng thái tổng thể của màn hình Home
enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Trạng thái cho các action (create / update / delete)
enum HomeActionStatus {
  idle,
  creating,
  updating,
  deleting,
}

class HomeState extends Equatable {
  /// Screen status
  final HomeStatus status;

  /// Action status
  final HomeActionStatus actionStatus;

  /// Data
  final List<Employee> employees;
  final Pagination? pagination;

  /// Messages
  final String? errorMessage;
  final String? successMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.actionStatus = HomeActionStatus.idle,
    this.employees = const [],
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory HomeState.initial() {
    return const HomeState();
  }

  /// CopyWith – immutable update
  HomeState copyWith({
    HomeStatus? status,
    HomeActionStatus? actionStatus,
    List<Employee>? employees,
    Pagination? pagination,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPagination = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      employees: employees ?? this.employees,
      pagination:
          clearPagination ? null : (pagination ?? this.pagination),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        actionStatus,
        employees,
        pagination,
        errorMessage,
        successMessage,
      ];
}
