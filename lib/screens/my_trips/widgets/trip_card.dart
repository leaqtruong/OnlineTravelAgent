import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/trip.dart';
import '../invoice_dialog.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (140 * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: RepaintBoundary(
              child: Image.asset(
                trip.imagePath,
                width: 140,
                height: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trip.destination,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trip.totalAmount > 0)
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => InvoiceDialog(trip: trip),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              size: 18,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.date,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.isUpcoming
                              ? const Color(0xFFE3F2FD)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: trip.isUpcoming
                                ? AppTheme.primaryBlue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
