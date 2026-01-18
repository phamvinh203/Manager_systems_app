import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/blocs/auth/auth_state.dart';
import 'package:mobile/core/helper/isRole_helper.dart';
import 'package:mobile/screens/workspace/admin/admin_task_page.dart';
import 'package:mobile/screens/workspace/widgets/create_task_fab.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Check if user is ADMIN, HR, or MANAGER
        if (authState.isAdmin || authState.isHR || authState.isManager) {
          return const AdminTaskPage();
        }

        // Default workspace screen for other roles
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Không gian làm việc',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_outline, size: 64, color: Color(0xFF9E9E9E)),
                SizedBox(height: 16),
                Text(
                  'Màn hình làm việc',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              authState.isAdmin || authState.isHR || authState.isManager
              ? const CreateTaskFAB()
              : null,
          bottomNavigationBar: const SizedBox(
            height: 80,
          ), // Lift FAB above navbar
        );
      },
    );
  }
}
