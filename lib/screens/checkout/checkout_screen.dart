import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/guest_counter.dart';
import 'payment_method_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const CheckoutScreen({super.key, required this.destination});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? _selectedDate;
  int _adults = 1;
  int _children = 0;
  bool _isVip = false;
  // For single-destination booking, guide is optional
  bool _includeGuide = false;
  static const double _guideFee = 50.0;
  String _selectedTransport = 'Tự túc';

  final Map<String, int> _transportPrices = {
    'Tự túc': 0,
    'Xe giường nằm': 20,
    'Tàu hoả': 35,
    'Máy bay': 100,
  };

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int get _basePrice => int.tryParse(widget.destination.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int get _totalGuests => _adults + _children;

  double get _subtotal {
    double adultPrice = _basePrice.toDouble() * _adults;
    double childPrice = _basePrice.toDouble() * 0.5 * _children;
    double sub = adultPrice + childPrice;
    if (_isVip) sub += 50 * _totalGuests;
    sub += _transportPrices[_selectedTransport]! * _totalGuests;
    if (_includeGuide) sub += _guideFee; // fixed guide fee for single-destination bookings
    return sub;
  }

  double get _tax => _subtotal * 0.1;

  double get _total => _subtotal + _tax;

  void _onConfirm() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày khởi hành')),
      );
      return;
    }

    // Calculate end date based on duration (simple logic)
    int days = 2;
    final match = RegExp(r'^(\d+)N').firstMatch(widget.destination.duration);
    if (match != null) {
      days = int.tryParse(match.group(1) ?? '2') ?? 2;
    }
    final endDate = _selectedDate!.add(Duration(days: days));

    final dateString = '${_dateFormat.format(_selectedDate!)} - ${_dateFormat.format(endDate)}';
    
    List<String> guestParts = [];
    if (_adults > 0) guestParts.add('$_adults Người lớn');
    if (_children > 0) guestParts.add('$_children Trẻ em');
    final guestString = '${guestParts.join(', ')} ($_selectedTransport)';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          totalPrice: _total,
          onPaymentSuccess: () async {
            if (!mounted) return false;
            return await ref.read(tripsProvider.notifier).bookTrip(
              destinationId: widget.destination.id,
              date: dateString,
              guests: guestString,
              totalPrice: _includeGuide ? _total : null,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDestinationCard(),
          const SizedBox(height: 24),
          _buildDateSelection(),
          const SizedBox(height: 24),
          _buildGuestSelection(),
          const SizedBox(height: 24),
          _buildRoomSelection(),
           const SizedBox(height: 24),
           _buildTransportSelection(),
           const SizedBox(height: 16),
           _buildGuideOption(),
           const SizedBox(height: 24),
           _buildSummaryCard(),
          const SizedBox(height: 32),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.destination.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              cacheWidth: (80 * MediaQuery.devicePixelRatioOf(context)).round(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destination.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.destination.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.destination.duration,
                    style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ngày khởi hành', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null ? 'Chọn ngày đi' : _dateFormat.format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                    fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hành khách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildGuestRow('Người lớn', 'Từ 12 tuổi', _adults, 1, (val) {
                if (val >= 1) setState(() => _adults = val);
              }),
              const Divider(height: 32),
              _buildGuestRow('Trẻ em', 'Dưới 12 tuổi', _children, 0, (val) {
                if (val >= 0) setState(() => _children = val);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestRow(String title, String subtitle, int count, int min, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        GuestCounter(value: count, min: min, onChanged: onChanged),
      ],
    );
  }

  Widget _buildRoomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loại dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildServiceOption('Standard', false),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceOption('VIP (+\$50/người)', true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceOption(String title, bool isVipOption) {
    final isSelected = _isVip == isVipOption;
    return InkWell(
      onTap: () => setState(() => _isVip = isVipOption),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransportSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phương tiện di chuyển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTransportOption('Tự túc', Icons.directions_walk, 0),
        const SizedBox(height: 8),
        _buildTransportOption('Xe giường nằm', Icons.directions_bus, 20),
        const SizedBox(height: 8),
        _buildTransportOption('Tàu hoả', Icons.train, 35),
        const SizedBox(height: 8),
        _buildTransportOption('Máy bay', Icons.flight, 100),
      ],
    );
  }

  Widget _buildGuideOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hướng dẫn viên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: const Text('Bao gồm hướng dẫn viên (phí cố định)', style: TextStyle(fontSize: 14)),
              ),
              Switch(
                value: _includeGuide,
                onChanged: (v) => setState(() => _includeGuide = v),
                activeThumbColor: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text('\$${_guideFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportOption(String title, IconData icon, int price) {
    final isSelected = _selectedTransport == title;
    return InkWell(
      onTap: () => setState(() => _selectedTransport = title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (price > 0)
              Text('+\$$price/người', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
          _buildSummaryRow('Giá vé người lớn (x$_adults)', '\$${_basePrice * _adults}'),
          if (_children > 0)
            _buildSummaryRow('Giá vé trẻ em (x$_children)', '\$${(_basePrice * 0.5 * _children).toStringAsFixed(0)}'),
          if (_isVip)
            _buildSummaryRow('Phí VIP (x$_totalGuests)', '\$${50 * _totalGuests}'),
          if (_transportPrices[_selectedTransport]! > 0)
            _buildSummaryRow('$_selectedTransport (x$_totalGuests)', '\$${_transportPrices[_selectedTransport]! * _totalGuests}'),
          const Divider(height: 24),
          _buildSummaryRow('Tạm tính', '\$${_subtotal.toStringAsFixed(0)}'),
          _buildSummaryRow('Thuế (10%)', '\$${_tax.toStringAsFixed(0)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '\$${_total.toStringAsFixed(0)}',
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

  Widget _buildConfirmButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: const Text(
          'Xác nhận & Thanh toán',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
