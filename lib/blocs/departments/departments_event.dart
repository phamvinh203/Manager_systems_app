import 'package:equatable/equatable.dart';

abstract class DepartmentsEvent extends Equatable {
  const DepartmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDepartments extends DepartmentsEvent {}

class LoadEmployeesByDepartment extends DepartmentsEvent {
  final int departmentId;

  const LoadEmployeesByDepartment(this.departmentId);

  @override
  List<Object?> get props => [departmentId];
}