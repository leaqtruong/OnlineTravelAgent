import 'package:flutter/material.dart';
import '../../../models/destination.dart';
import '../../../core/theme/app_theme.dart';

class RecommendedDestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onClick;

  const RecommendedDestinationCard({
    super.key,
    required this.destination,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 174,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                        destination.imagePath,
                        height: 96,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.darkGray,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        destination.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                destination.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textBlack),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.blueAccent, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Ưu đãi đặc biệt",
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
