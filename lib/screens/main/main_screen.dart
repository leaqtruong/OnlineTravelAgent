import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination.dart';
import '../../providers/travel_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../my_trips/my_trips_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Theo dõi tab đã được truy cập — chỉ build tab khi user chọn lần đầu
  final Set<int> _visitedTabs = {0}; // Tab 0 (Dashboard) mặc định đã truy cập

  final List<String> _titles = ["Khám phá", "Chuyến đi", "Yêu thích", "Cá nhân"];
  final List<IconData> _icons = [
    Icons.home,
    Icons.confirmation_number,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<TravelProvider, Destination?>(
      selector: (_, provider) => provider.selectedDestination,
      builder: (context, selectedDestination, _) {
        return Scaffold(
          body: selectedDestination != null
              ? DestinationDetailScreen(
                  destination: selectedDestination,
                  onBackClick: () => context.read<TravelProvider>().selectDestination(null),
                  onFavoriteClick: () => context.read<TravelProvider>().toggleFavorite(selectedDestination.name),
                )
              : _buildLazyIndexedStack(),
          bottomNavigationBar: selectedDestination == null
              ? _buildBottomNavigationBar()
              : null,
        );
      },
    );
  }

  /// Lazy IndexedStack: chỉ build tab khi user chọn lần đầu
  Widget _buildLazyIndexedStack() {
    return IndexedStack(
      index: _selectedIndex,
      children: List.generate(4, (index) {
        // Chỉ build widget khi tab đã được truy cập
        if (!_visitedTabs.contains(index)) {
          return const SizedBox.shrink();
        }
        return _buildTabContent(index);
      }),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          onDestinationClick: (dest) => context.read<TravelProvider>().selectDestination(dest),
        );
      case 1:
        return const MyTripsScreen();
      case 2:
        return FavoritesScreen(
          onDestinationClick: (dest) => context.read<TravelProvider>().selectDestination(dest),
        );
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _visitedTabs.add(index); // Đánh dấu tab đã truy cập
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey.withValues(alpha: 0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: List.generate(
            _titles.length,
            (index) => BottomNavigationBarItem(
              icon: Icon(_icons[index]),
              label: _titles[index],
            ),
          ),
        ),
      ),
    );
  }
}
