import 'package:mobile/models/department_model.dart';

abstract class DepartmentsState {}

class DepartmentsInitial extends DepartmentsState {}

class DepartmentsLoading extends DepartmentsState {}

class DepartmentsLoaded extends DepartmentsState {
  final List<Department> departments;
  DepartmentsLoaded(this.departments);
}

class EmployeesByDepartmentLoading extends DepartmentsState {}

class EmployeesByDepartmentLoaded extends DepartmentsState {
  final List<DepartmentEmployee> employees;
  final int departmentId;
  EmployeesByDepartmentLoaded(this.employees, this.departmentId);
}

class DepartmentsError extends DepartmentsState {
  final String message;
  DepartmentsError(this.message);
}