import 'package:mobile/models/department_model.dart';

abstract class DepartmentsState {}

class DepartmentsInitial extends DepartmentsState {}

class DepartmentsLoading extends DepartmentsState {}

class DepartmentsLoaded extends DepartmentsState {
  final List<Department> departments;
  DepartmentsLoaded(this.departments);
}

class DepartmentsError extends DepartmentsState {
  final String message;
  DepartmentsError(this.message);
}