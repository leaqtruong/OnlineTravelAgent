import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Xu hướng tuần này',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _TrendCard(
                  icon: Icons.weekend,
                  title: 'City Break 48h',
                  subtitle: 'Hà Nội, Đà Nẵng, Sài Gòn',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TrendCard(
                  icon: Icons.spa,
                  title: 'Nghỉ dưỡng chill',
                  subtitle: 'Biển xanh, resort yên tĩnh',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrendCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
