import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination.dart';
import '../../providers/travel_provider.dart';
import 'widgets/favorite_destination_card.dart';

class FavoritesScreen extends StatelessWidget {
  final Function(Destination) onDestinationClick;

  const FavoritesScreen({super.key, required this.onDestinationClick});

  @override
  Widget build(BuildContext context) {
    final favorites = context.select<TravelProvider, List<Destination>>((p) => p.favorites);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Địa điểm yêu thích",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              favorites.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text("Chưa có địa điểm yêu thích nào",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        itemCount: favorites.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemBuilder: (context, index) {
                          return FavoriteDestinationCard(
                            destination: favorites[index],
                            onFavoriteClick: () => context.read<TravelProvider>()
                                .toggleFavorite(favorites[index].id),
                            onClick: () => onDestinationClick(favorites[index]),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
