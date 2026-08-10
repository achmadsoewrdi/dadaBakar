import 'package:flutter/material.dart';

class BlynkSwitchWidget extends StatelessWidget {
  final String title;
  final String pin;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color themeColor;
  final VoidCallback? onDelete;

  const BlynkSwitchWidget({
    super.key,
    required this.title,
    required this.pin,
    required this.value,
    required this.onChanged,
    required this.themeColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: value ? themeColor : Colors.grey.shade200,
          width: value ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: value ? themeColor.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: value ? themeColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: value ? themeColor : Colors.grey.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Pin: $pin  •  ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        value ? 'AKTIF (ON)' : 'MATI (OFF)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: value ? themeColor : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Switch(
                value: value,
                activeTrackColor: themeColor,
                onChanged: onChanged,
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
