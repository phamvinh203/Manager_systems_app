import 'package:equatable/equatable.dart';
import 'package:mobile/models/employee_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// LOAD EMPLOYEES

/// Load lần đầu (page = 1)
class LoadEmployeesEvent extends HomeEvent {
  final int limit;

  const LoadEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Pull to refresh (reset page = 1)
class RefreshEmployeesEvent extends HomeEvent {
  final int limit;

  const RefreshEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Load more (page = current + 1)
class LoadMoreEmployeesEvent extends HomeEvent {
  final int limit;

  const LoadMoreEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// CRUD EVENTS

class CreateEmployeeEvent extends HomeEvent {
  final Employee employee;

  const CreateEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends HomeEvent {
  final int employeeId;
  final Employee employee;

  const UpdateEmployeeEvent(this.employeeId, this.employee);

  @override
  List<Object?> get props => [employeeId, employee];
}

class DeleteEmployeeEvent extends HomeEvent {
  final int employeeId;

  const DeleteEmployeeEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

/// UI EVENTS

class ClearMessagesEvent extends HomeEvent {
  const ClearMessagesEvent();
}
