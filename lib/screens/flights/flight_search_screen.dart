import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/flight.dart';
import '../../providers/flight_provider.dart';
import 'flight_checkout_screen.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  String? _selectedAirline;
  String _departure = 'SGN';
  String _arrival = 'HAN';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _airlines = ['Tất cả', 'Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'];
  final List<String> _airports = ['SGN', 'HAN', 'DLI', 'PQC', 'DAD'];

  void _swapAirports() {
    setState(() {
      final temp = _departure;
      _departure = _arrival;
      _arrival = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flightsAsync = ref.watch(flightsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tìm chuyến bay',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSearchForm(),
          ),
          SliverToBoxAdapter(
            child: _buildAirlineFilter(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: flightsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Không thể tải dữ liệu chuyến bay',
                            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(flightsProvider),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (flights) {
                final displayed = flights.where((f) {
                  bool matchDep = f.departure == _departure;
                  bool matchArr = f.arrival == _arrival;
                  bool matchAirline = _selectedAirline == null || _selectedAirline == 'Tất cả' || f.airline == _selectedAirline;
                  return matchDep && matchArr && matchAirline;
                }).toList();

                if (displayed.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildFlightCard(displayed[index]),
                    childCount: displayed.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Từ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _departure,
                          isDense: true,
                          icon: const SizedBox.shrink(),
                          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                          items: _airports.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _departure = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _swapAirports,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz, color: AppTheme.primaryBlue, size: 20),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Đến', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _arrival,
                          isDense: true,
                          icon: const SizedBox.shrink(),
                          alignment: Alignment.centerRight,
                          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                          items: _airports.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _arrival = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppTheme.primaryBlue,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirlineFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _airlines.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final airline = _airlines[index];
          final isSelected = (_selectedAirline == airline) || (_selectedAirline == null && airline == 'Tất cả');
          return InkWell(
            onTap: () => setState(() => _selectedAirline = airline),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(
                airline,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlightCard(Flight flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlightCheckoutScreen(
                  flight: flight,
                  date: DateFormat('dd/MM/yyyy').format(_selectedDate),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              flight.airlineLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.flight, size: 16, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          flight.airline,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '\$${flight.price}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(flight.departureTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(flight.departure, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(flight.duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), shape: BoxShape.circle)),
                            Container(width: 40, height: 1, color: Colors.grey.shade300),
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Bay thẳng', style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(flight.arrivalTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(flight.arrival, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.flight_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy chuyến bay',
              style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng thử đổi ngày hoặc sân bay khác',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
