import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/repositories/employee_repository.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository employeeRepository;
  final Logger _logger = Logger();

  EmployeeBloc(this.employeeRepository) : super(const EmployeeState()) {
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<LoadMoreEmployeesEvent>(_onLoadMoreEmployees);
    on<GoToPageEvent>(_onGoToPage);
    on<RefreshEmployeesEvent>(_onRefreshEmployees);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
    on<CreateEmployeeEvent>(_onCreateEmployee);
    on<UpdateEmployeeEvent>(_onUpdateEmployee);
    on<ClearMessagesEvent>(_onClearMessages);
    on<LoadCurrentEmployeeEvent>(_onLoadCurrentEmployee);
  }
  // Clear messages
  void _onClearMessages(ClearMessagesEvent event, Emitter<EmployeeState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  // Load employees
  Future<void> _onLoadEmployees(
    LoadEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      final response = await employeeRepository.getEmployees(
        page: 1,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: EmployeeStatus.loaded,
          employees: response.employees,
          pagination: response.pagination,
        ),
      );

      _logger.i(
        'Loaded ${response.employees.length} employees (page ${response.pagination.page})',
      );
    } catch (e) {
      _logger.e('Load employees error: $e');

      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Failed to load employees',
        ),
      );
    }
  }

  // Load more employees
  Future<void> _onLoadMoreEmployees(
    LoadMoreEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    final pagination = state.pagination;
    if (pagination == null) return;

    final currentPage = pagination.page;
    final totalPages = pagination.totalPages;

    // Không còn trang để load
    if (currentPage >= totalPages) return;

    try {
      final response = await employeeRepository.getEmployees(
        page: currentPage + 1,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          employees: [...state.employees, ...response.employees],
          pagination: response.pagination,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load more employees'));
    }
  }

  // Go to specific page
  Future<void> _onGoToPage(
    GoToPageEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatus.loading));

    try {
      final response = await employeeRepository.getEmployees(
        page: event.page,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: EmployeeStatus.loaded,
          employees: response.employees,
          pagination: response.pagination,
        ),
      );

      _logger.i(
        'Loaded ${response.employees.length} employees (page ${response.pagination.page})',
      );
    } catch (e) {
      _logger.e('Go to page error: $e');

      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Failed to load page',
        ),
      );
    }
  }

  // Refresh employees
  Future<void> _onRefreshEmployees(
    RefreshEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      final response = await employeeRepository.getEmployees(
        page: 1,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: EmployeeStatus.loaded,
          employees: response.employees,
          pagination: response.pagination,
          clearError: true,
        ),
      );

      _logger.i('Refreshed ${response.employees.length} employees');
    } catch (e) {
      _logger.e('Refresh employees error: $e');

      emit(state.copyWith(errorMessage: 'Failed to refresh employees'));
    }
  }

  // Delete employee
  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await employeeRepository.delete(event.employeeId);

      final updatedEmployees = state.employees
          .where((e) => e.id != event.employeeId)
          .toList();

      emit(
        state.copyWith(
          employees: updatedEmployees,
          successMessage: 'Employee deleted successfully',
        ),
      );

      _logger.i('Deleted employee ${event.employeeId}');
    } catch (e) {
      _logger.e('Delete employee error: $e');

      emit(state.copyWith(errorMessage: 'Failed to delete employee'));
    }
  }

  // Create employee
  Future<void> _onCreateEmployee(
    CreateEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      final newEmployee = await employeeRepository.create(event.employee);

      emit(
        state.copyWith(
          employees: [newEmployee, ...state.employees],
          successMessage: 'Employee created successfully',
        ),
      );

      _logger.i('Created employee: ${newEmployee.fullName}');
    } catch (e) {
      _logger.e('Create employee error: $e');

      emit(state.copyWith(errorMessage: 'Failed to create employee'));
    }
  }

  // Update employee
  Future<void> _onUpdateEmployee(
    UpdateEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      final updatedEmployee = await employeeRepository.update(
        event.employeeId,
        event.employee,
      );

      final updatedEmployees = state.employees.map((e) {
        return e.id == event.employeeId ? updatedEmployee : e;
      }).toList();

      emit(
        state.copyWith(
          employees: updatedEmployees,
          successMessage: 'Employee updated successfully',
        ),
      );

      _logger.i('Updated employee: ${updatedEmployee.fullName}');
    } catch (e) {
      _logger.e('Update employee error: $e');

      emit(state.copyWith(errorMessage: 'Failed to update employee'));
    }
  }

  // Load current employee
  Future<void> _onLoadCurrentEmployee(
    LoadCurrentEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      final employee = await employeeRepository.fetchEmployeeById(event.employeeId);

      emit(
        state.copyWith(
          currentEmployee: employee,
        ),
      );

      _logger.i('Loaded current employee: ${employee.fullName}');
    } catch (e) {
      _logger.e('Load current employee error: $e');

      emit(state.copyWith(errorMessage: 'Failed to load current employee'));
    }
  }
}
