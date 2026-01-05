import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'widgets/employee_search_bar.dart';
import 'widgets/employee_list.dart';
import 'widgets/add_member_button.dart';
import 'add_employee.dart';
import '../widgets/pagination_widget.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const LoadEmployeesEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: EmployeeSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    context
                        .read<EmployeeBloc>()
                        .add(SearchEmployeesEvent(query));
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Employee list
            const Expanded(child: EmployeeList()),

            // Pagination
            BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                if (state.pagination == null) {
                  return const SizedBox.shrink();
                }

                return PaginationWidget(
                  currentPage: state.pagination!.page,
                  totalPages: state.pagination!.totalPages,
                  onPageChanged: (page) {
                    context
                    .read<EmployeeBloc>()
                    .add(GoToPageEvent(page));
                  },
                );
              },
            ),

            // Add member button
            AddMemberButton(
              onPressed: () async{
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
                );

                context
                    .read<EmployeeBloc>()
                    .add(const LoadEmployeesEvent());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
