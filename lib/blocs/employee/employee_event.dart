import 'package:mobile/models/employee_model.dart';
import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployeesEvent extends EmployeeEvent {
  final int limit;

  const LoadEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Pull to refresh (reset page = 1)
class RefreshEmployeesEvent extends EmployeeEvent {
  final int limit;

  const RefreshEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Load more (page = current + 1)
class LoadMoreEmployeesEvent extends EmployeeEvent {
  final int limit;

  const LoadMoreEmployeesEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Go to specific page
class GoToPageEvent extends EmployeeEvent {
  final int page;
  final int limit;

  const GoToPageEvent(this.page, {this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

/// CRUD EVENTS

class CreateEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  const CreateEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final int employeeId;
  final Employee employee;

  const UpdateEmployeeEvent(this.employeeId, this.employee);

  @override
  List<Object?> get props => [employeeId, employee];
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final int employeeId;

  const DeleteEmployeeEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

/// UI EVENTS

class ClearMessagesEvent extends EmployeeEvent {
  const ClearMessagesEvent();
}

class SearchEmployeesEvent extends EmployeeEvent {
  final String query;

  const SearchEmployeesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Load current employee by userId (sau khi login)
class LoadCurrentEmployeeEvent extends EmployeeEvent {
  final int userId;

  const LoadCurrentEmployeeEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
