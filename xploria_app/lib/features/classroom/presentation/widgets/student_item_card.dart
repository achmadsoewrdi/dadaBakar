import 'package:flutter/material.dart';

class StudentItemCard extends StatelessWidget {
  final String initial;
  final String name;
  final String taskProgress;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;

  const StudentItemCard({
    Key? key,
    required this.initial,
    required this.name,
    required this.taskProgress,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F0FE),
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B5BDB),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            taskProgress,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
