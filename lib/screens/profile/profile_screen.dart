import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/blocs/auth/auth_event.dart';
import 'package:mobile/blocs/auth/auth_state.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/profile/widgets/profile_detail.dart';
import 'package:mobile/screens/profile/widgets/profile_setting.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_items.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadCurrentEmployee();
  }

  Future<void> _loadCurrentEmployee() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null && mounted) {
      context.read<EmployeeBloc>().add(LoadCurrentEmployeeEvent(userId));
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              // Trigger logout event
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            final employee = state.currentEmployee;

            if (employee == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _loadCurrentEmployee,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Profile Header
                    ProfileHeader(employee: employee),

                    const SizedBox(height: 24),

                    // Menu Items
                    ProfileMenuItems(
                      onMyProfileTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileDetail(),
                          ),
                        );
                      },
                      onSettingsTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSetting(),
                          ),
                        );
                      },
                      onTermsTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terms & Conditions - Coming soon!'),
                          ),
                        );
                      },
                      onPrivacyTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy - Coming soon!'),
                          ),
                        );
                      },
                      onLogoutTap: _handleLogout,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
