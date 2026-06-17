import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final int adults;
  final int children;
  final int basePrice;
  final bool isVip;
  final int totalGuests;
  final String selectedTransport;
  final Map<String, int> transportPrices;
  final double subtotal;
  final double tax;
  final double total;

  const SummaryCard({
    super.key,
    required this.adults,
    required this.children,
    required this.basePrice,
    required this.isVip,
    required this.totalGuests,
    required this.selectedTransport,
    required this.transportPrices,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi tiết thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSummaryRow('Giá vé người lớn (x$adults)', '\$${basePrice * adults}'),
          if (children > 0)
            _buildSummaryRow('Giá vé trẻ em (x$children)', '\$${(basePrice * 0.5 * children).toStringAsFixed(0)}'),
          if (isVip)
            _buildSummaryRow('Phí VIP (x$totalGuests)', '\$${50 * totalGuests}'),
          if (transportPrices[selectedTransport]! > 0)
            _buildSummaryRow('$selectedTransport (x$totalGuests)', '\$${transportPrices[selectedTransport]! * totalGuests}'),
          const Divider(height: 24),
          _buildSummaryRow('Tạm tính', '\$${subtotal.toStringAsFixed(0)}'),
          _buildSummaryRow('Thuế (10%)', '\$${tax.toStringAsFixed(0)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
