// departments_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/departments/departments_event.dart';
import 'package:mobile/blocs/departments/departments_state.dart';
import 'package:mobile/repositories/departments_repository.dart';

class DepartmentsBloc extends Bloc<DepartmentsEvent, DepartmentsState> {
  final DepartmentsRepository repository;

  DepartmentsBloc({required this.repository}) : super(DepartmentsInitial()) {
    on<LoadDepartments>(_onLoadDepartments);
    on<LoadEmployeesByDepartment>(_onLoadEmployeesByDepartment);
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<DepartmentsState> emit,
  ) async {
    emit(DepartmentsLoading());
    try {
      final departments = await repository.getDepartments();
      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(DepartmentsError(e.toString()));
    }
  }

  Future<void> _onLoadEmployeesByDepartment(
    LoadEmployeesByDepartment event,
    Emitter<DepartmentsState> emit,
  ) async {
    emit(EmployeesByDepartmentLoading());
    try {
      final employees = await repository.getEmployeesByDepartment(event.departmentId);
      emit(EmployeesByDepartmentLoaded(employees, event.departmentId));
    } catch (e) {
      emit(DepartmentsError(e.toString()));
    }
  }
}