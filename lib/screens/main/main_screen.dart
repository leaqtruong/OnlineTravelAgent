import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final List<String> _titles = ["Khám phá", "Chuyến đi", "Yêu thích", "Cá nhân"];
  final List<IconData> _icons = [
    Icons.home,
    Icons.confirmation_number,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final travelProvider = Provider.of<TravelProvider>(context);
    final selectedDestination = travelProvider.selectedDestination;

    return Scaffold(
      body: selectedDestination != null
          ? DestinationDetailScreen(
              destination: selectedDestination,
              onBackClick: () => travelProvider.selectDestination(null),
              onFavoriteClick: () => travelProvider.toggleFavorite(selectedDestination.name),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(
                  onDestinationClick: (dest) => travelProvider.selectDestination(dest),
                ),
                const MyTripsScreen(),
                FavoritesScreen(
                  onDestinationClick: (dest) => travelProvider.selectDestination(dest),
                ),
                const ProfileScreen(),
              ],
            ),
      bottomNavigationBar: selectedDestination == null
          ? Container(
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
            )
          : null,
    );
  }
}
