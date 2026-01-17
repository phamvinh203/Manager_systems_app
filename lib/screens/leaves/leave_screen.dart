import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/helper/isRole_helper.dart';

import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/blocs/auth/auth_state.dart';

import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/repositories/leave_request_repository.dart';
import 'package:mobile/screens/leaves/manager/TabManager.dart';

import 'package:mobile/screens/leaves/widgets/button_leave.dart';
import 'package:mobile/screens/leaves/widgets/list_leave_request.dart';

import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/repositories/departments_repository.dart';
import 'package:mobile/screens/leaves/hr/TabFilterChip.dart';
import 'package:mobile/models/department_model.dart';
import 'package:mobile/models/user_model.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  int _currentTabIndex = 0; // 0: Team Requests, 1: My Leaves

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    User? currentUser;
    if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }

    // Default tab index for non-managers should be My Leaves (1)
    if (currentUser != null && !currentUser.isManager && !currentUser.isHR) {
      _currentTabIndex = 1;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DepartmentsBloc(repository: DepartmentsRepository()),
        ),
        BlocProvider(
          create: (context) {
            final bloc = LeaveRequestBloc(LeaveRequestRepository());
            _loadInitialData(bloc, currentUser);
            return bloc;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Quản lý nghỉ phép',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            body: Column(
              children: [
                // Tabs for Manager or HR
                if (currentUser != null && (currentUser.isManager))
                  Tabmanager(
                    currentIndex: _currentTabIndex,
                    onTabChanged: (index) {
                      setState(() => _currentTabIndex = index);
                      _onTabChanged(context, index, currentUser);
                    },
                  ),

                // Department filter for HR when on Team/All Requests tab
                if (currentUser != null &&
                    currentUser.isHR &&
                    _currentTabIndex == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TabFilterChip(
                      onSelected: (Department? department) {
                        context.read<LeaveRequestBloc>().add(
                          LoadAllLeaveRequestsEvent(
                            departmentId: department?.id,
                          ),
                        );
                      },
                    ),
                  ),

                const Expanded(child: ListLeaveRequest()),
              ],
            ),
            floatingActionButton: const ButtonLeave(),
          );
        },
      ),
    );
  }

  void _loadInitialData(LeaveRequestBloc bloc, User? user) {
    if (user == null) {
      bloc.add(const LoadLeaveRequestsEvent());
      return;
    }

    if (user.isHR) {
      bloc.add(const LoadAllLeaveRequestsEvent());
    } else if (user.isManager) {
      // Manager starts with Team Requests
      bloc.add(const LoadTeamLeaveRequestsEvent());
    } else {
      bloc.add(const LoadLeaveRequestsEvent());
    }
  }

  void _onTabChanged(BuildContext context, int index, User? user) {
    final bloc = context.read<LeaveRequestBloc>();
    if (index == 0) {
      // Team Requests
      if (user?.isHR ?? false) {
        bloc.add(const LoadAllLeaveRequestsEvent());
      } else {
        bloc.add(const LoadTeamLeaveRequestsEvent());
      }
    } else {
      // My Leaves
      bloc.add(const LoadLeaveRequestsEvent());
    }
  }
}
