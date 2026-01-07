import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_bloc.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/positions/positions_bloc.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/repositories/auth_repository.dart';
import 'package:mobile/repositories/attendance_repository.dart';
import 'package:mobile/repositories/departments_repository.dart';
import 'package:mobile/repositories/employee_repository.dart';
import 'package:mobile/repositories/positions_repository.dart';
import 'package:mobile/screens/auth/login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => EmployeeRepository()),
        RepositoryProvider(create: (_) => AttendanceRepository()),
        RepositoryProvider(create: (_) => DepartmentsRepository()),
        RepositoryProvider(create: (_) => PositionsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => EmployeeBloc(context.read<EmployeeRepository>()),
          ),
          BlocProvider(
            create: (context) => AttendanceBloc(context.read<AttendanceRepository>()),
          ),
          BlocProvider(
            create: (context) => DepartmentsBloc(
              repository: context.read<DepartmentsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PositionsBloc(
              repository: context.read<PositionsRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Manager App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}

