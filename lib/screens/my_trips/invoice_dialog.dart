import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../providers/travel_provider.dart';
import '../checkout/vnpay_payment_dialog.dart';

class InvoiceDialog extends StatelessWidget {
  final Trip trip;

  const InvoiceDialog({super.key, required this.trip});

  String get _bookingCode =>
      'BK-${trip.id.toUpperCase().hashCode.toString().substring(0, 6)}';

  @override
  Widget build(BuildContext context) {
    final amountUsd = trip.totalAmount;
    const usdToVnd = 25000.0;
    final amountVnd = amountUsd * usdToVnd;
    final numberFormat = NumberFormat('#,###', 'vi_VN');
    final isPaid = trip.status == 'Đã thanh toán' || trip.status == 'Sắp tới';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hoá đơn thanh toán',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _row('Điểm đến', trip.destination),
                    _row('Địa điểm', trip.location),
                    _row('Ngày đi', trip.date),
                    _row('Hành khách', trip.guests.isEmpty ? '—' : trip.guests),
                    _row('Mã đặt chỗ', _bookingCode),
                    _row('Trạng thái', trip.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${amountUsd.toStringAsFixed(0)} USD',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~ ${numberFormat.format(amountVnd.round())} VND',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!isPaid)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _onPay(context, amountVnd),
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    label: const Text(
                      'Thanh toán ngay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Đã thanh toán',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _onPay(BuildContext context, double amountVnd) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => _PaymentProcessingDialog(trip: trip, amountVnd: amountVnd),
    );
  }
}

class _PaymentProcessingDialog extends StatelessWidget {
  final Trip trip;
  final double amountVnd;

  const _PaymentProcessingDialog({required this.trip, required this.amountVnd});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TravelProvider>();

    return FutureBuilder<Map<String, dynamic>?>(
      future: provider.createVNPayPayment(
        amountVnd: amountVnd,
        orderInfo: 'Thanh toan ${trip.destination}',
        tripId: trip.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tạo mã thanh toán...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Không thể tạo mã thanh toán. Vui lòng thử lại.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final paymentUrl = data['paymentUrl'] as String;
        final txnRef = data['txnRef'] as String;

        return VNPayPaymentDialog(
          paymentUrl: paymentUrl,
          txnRef: txnRef,
          amountVnd: amountVnd,
          onCheckPayment: () {
            Navigator.of(context).pop();
            _showSuccess(context);
          },
        );
      },
    );
  }

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 24),
            Text(
              'Thanh toán thành công!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Cảm ơn bạn đã thanh toán. Chúc bạn có chuyến đi vui vẻ!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Về trang chủ'),
            ),
          ),
        ],
      ),
    );
  }
}
