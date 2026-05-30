import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TripActionButtons extends StatelessWidget {
  const TripActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _btn(context, Icons.support_agent, 'Hỗ trợ'),
        _btn(context, Icons.receipt_long, 'Hóa đơn'),
        _btn(context, Icons.share_outlined, 'Chia sẻ'),
        _btn(context, Icons.cancel_outlined, 'Hủy vé'),
      ],
    );
  }

  Widget _btn(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label — Tính năng đang phát triển'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
