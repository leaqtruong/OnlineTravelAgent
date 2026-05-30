import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/travel_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../favorites/favorites_screen.dart';
import '../my_trips/my_trips_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Track visited tabs and only build them after first selection.
  final Set<int> _visitedTabs = {0};

  final List<String> _titles = [
    "Khám phá",
    "Chuyến đi",
    "Yêu thích",
    "Cá nhân"
  ];
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
                  onBackClick: () =>
                      context.read<TravelProvider>().selectDestination(null),
                  onFavoriteClick: () => context
                      .read<TravelProvider>()
                      .toggleFavorite(selectedDestination.id),
                )
              : _buildLazyIndexedStack(),
          bottomNavigationBar:
              selectedDestination == null ? _buildBottomNavigationBar() : null,
        );
      },
    );
  }

  Widget _buildLazyIndexedStack() {
    return IndexedStack(
      index: _selectedIndex,
      children: List.generate(4, (index) {
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
          onDestinationClick: (dest) =>
              context.read<TravelProvider>().selectDestination(dest),
        );
      case 1:
        return const MyTripsScreen();
      case 2:
        return FavoritesScreen(
          onDestinationClick: (dest) =>
              context.read<TravelProvider>().selectDestination(dest),
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
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Transform.translate(
            offset: const Offset(0, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _visitedTabs.add(index);
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppTheme.primaryBlue,
                unselectedItemColor: Colors.grey.withValues(alpha: 0.5),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                iconSize: 30,
                selectedLabelStyle: const TextStyle(fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
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
          ),
        ),
      ),
    );
  }
}
