import 'package:flutter/material.dart';
import 'package:mobile/screens/workspace/widgets/create_task.dart';

class CreateTaskFAB extends StatelessWidget {
  const CreateTaskFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'create_task_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateTaskPage()),
        );
      },
      backgroundColor: const Color(0xFF2F80ED),
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
