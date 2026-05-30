import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/flight.dart';
import '../../providers/travel_provider.dart';
import '../checkout/payment_method_screen.dart';

class FlightCheckoutScreen extends StatefulWidget {
  final Flight flight;
  final String date;

  const FlightCheckoutScreen({
    super.key,
    required this.flight,
    required this.date,
  });

  @override
  State<FlightCheckoutScreen> createState() => _FlightCheckoutScreenState();
}

class _FlightCheckoutScreenState extends State<FlightCheckoutScreen> {
  int _adults = 1;
  int _children = 0;
  bool _isBusinessClass = false;
  int _extraBaggage = 0; // 0, 15, 20 kg

  double get _totalPrice {
    final basePrice = widget.flight.price.toDouble();
    final adultPrice = basePrice * _adults;
    final childPrice = basePrice * 0.75 * _children; // Children are 75%
    final classMultiplier = _isBusinessClass ? 2.0 : 1.0;
    
    double baggagePrice = 0;
    if (_extraBaggage == 15) baggagePrice = 20;
    if (_extraBaggage == 20) baggagePrice = 30;

    return (adultPrice + childPrice) * classMultiplier + baggagePrice;
  }

  void _navigateToPayment() {
    final String guestsStr = '$_adults Người lớn, $_children Trẻ em'
        '${_isBusinessClass ? ' (Thương gia)' : ' (Phổ thông)'}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          totalPrice: _totalPrice,
          onPaymentSuccess: () async {
            if (!mounted) return false;
            final provider = context.read<TravelProvider>();
            return await provider.bookFlight(
              flightId: widget.flight.id,
              date: widget.date,
              guests: guestsStr,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Thanh toán vé máy bay'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightSummary(),
            const SizedBox(height: 24),
            _buildPassengerSection(),
            const SizedBox(height: 24),
            _buildClassOptions(),
            const SizedBox(height: 24),
            _buildBaggageOptions(),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildFlightSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.flight.airline,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                widget.date,
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLocation(widget.flight.departureTime, widget.flight.departure),
              Column(
                children: [
                  const Icon(Icons.flight_takeoff, color: AppTheme.primaryBlue),
                  const SizedBox(height: 4),
                  Text(widget.flight.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              _buildTimeLocation(widget.flight.arrivalTime, widget.flight.arrival),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLocation(String time, String location) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildPassengerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành khách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCounterRow(
          title: 'Người lớn',
          subtitle: 'Từ 12 tuổi trở lên',
          value: _adults,
          onChanged: (val) {
            if (val >= 1) setState(() => _adults = val);
          },
        ),
        const SizedBox(height: 12),
        _buildCounterRow(
          title: 'Trẻ em',
          subtitle: 'Dưới 12 tuổi',
          value: _children,
          onChanged: (val) {
            if (val >= 0) setState(() => _children = val);
          },
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: value > 0 ? AppTheme.primaryBlue : Colors.grey,
              onPressed: () => onChanged(value - 1),
            ),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.primaryBlue,
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hạng ghế',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isBusinessClass = false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: !_isBusinessClass ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.white,
                    border: Border.all(color: !_isBusinessClass ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Phổ thông\n(Tiêu chuẩn)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isBusinessClass ? AppTheme.primaryBlue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isBusinessClass = true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isBusinessClass ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.white,
                    border: Border.all(color: _isBusinessClass ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Thương gia\n(Giá x2)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isBusinessClass ? AppTheme.primaryBlue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBaggageOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành lý ký gửi bổ sung',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildBaggageOption('Không mang thêm (Chỉ 7kg xách tay)', 0, 0),
        const SizedBox(height: 8),
        _buildBaggageOption('+15 kg hành lý ký gửi', 15, 20),
        const SizedBox(height: 8),
        _buildBaggageOption('+20 kg hành lý ký gửi', 20, 30),
      ],
    );
  }

  Widget _buildBaggageOption(String title, int value, int price) {
    final isSelected = _extraBaggage == value;
    return GestureDetector(
      onTap: () => setState(() => _extraBaggage = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            ),
            if (price > 0)
              Text('+\$$price', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _navigateToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
