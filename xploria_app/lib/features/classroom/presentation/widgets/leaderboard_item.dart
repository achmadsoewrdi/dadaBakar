import 'package:flutter/material.dart';

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String initial;
  final String name;
  final String xp;

  const LeaderboardItem({
    Key? key,
    required this.rank,
    required this.initial,
    required this.name,
    required this.xp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFF59E0B); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFF94A3B8); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFB45309); // Bronze
    } else {
      rankColor = const Color(0xFFCBD5E1); // Grey
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          // Rank Circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Avatar
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
          
          // Name
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
          
          // XP
          Text(
            xp,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF003092),
            ),
          ),
        ],
      ),
    );
  }
}
