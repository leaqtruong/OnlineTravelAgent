import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                trip.imagePath,
                fit: BoxFit.cover,
                cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade300),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.destination,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trip.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: trip.isUpcoming
                              ? const Color(0xFFE3F2FD)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trip.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: trip.isUpcoming
                                ? AppTheme.primaryBlue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 24),
                  const Text(
                    "Thông tin đặt chỗ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, "Ngày đi", trip.date),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, "Hành khách", trip.guests),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.confirmation_num_outlined, "Mã đặt chỗ",
                      "BK-${trip.id.toUpperCase().hashCode.toString().substring(0, 6)}"),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 24),
                  const Text(
                    "Tiện ích chuyến đi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionBtn(context, Icons.support_agent, "Hỗ trợ"),
                      _buildActionBtn(context, Icons.receipt_long, "Hóa đơn"),
                      _buildActionBtn(context, Icons.cancel_outlined, "Hủy vé"),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF555555)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label) {
    return Column(
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
    );
  }
}
