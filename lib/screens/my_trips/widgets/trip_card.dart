import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  String _getClassificationLabel() {
    if (trip.isCustom) {
      return 'Tự thiết kế';
    } else if (trip.flightId != null) {
      return 'Chuyến bay';
    } else if (trip.hotelId != null) {
      return 'Khách sạn';
    }
    return 'Gói Tour';
  }

  LinearGradient _getClassificationGradient() {
    if (trip.isCustom) {
      return const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (trip.flightId != null) {
      return const LinearGradient(
        colors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (trip.hotelId != null) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (140 * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      height: 142,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Left: Image section with dynamic classification badge
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 126,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: RepaintBoundary(
                      child: Image.asset(
                        trip.imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 30, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Dark semi-gradient overlay on image top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Float Classification Tag
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: _getClassificationGradient(),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getClassificationLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: Detailed Info block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Destination
                  Text(
                    trip.destination,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Row 2: Booking Info (Date & Guests)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.date,
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 10,
                        color: Colors.grey.withValues(alpha: 0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Icon(Icons.people_alt_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        trip.guests,
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  // Row 3: Location and Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_sharp,
                              size: 13,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.location,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.status.toLowerCase() == 'đang diễn ra' || trip.status.toLowerCase() == 'ongoing'
                              ? const Color(0xFFFF9800).withValues(alpha: 0.1)
                              : trip.isUpcoming
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                                  : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: trip.status.toLowerCase() == 'đang diễn ra' || trip.status.toLowerCase() == 'ongoing'
                                ? const Color(0xFFFF9800)
                                : trip.isUpcoming
                                    ? AppTheme.primaryBlue
                                    : Colors.grey[600],
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
