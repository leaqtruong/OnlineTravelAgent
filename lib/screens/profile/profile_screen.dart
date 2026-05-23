import 'package:flutter/material.dart';
import '../../models/trip.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/document_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DocumentItem> documents = [
      DocumentItem(title: "Hộ chiếu", description: "Hết hạn: 12/2030", icon: Icons.description, color: const Color(0xFF176FF2)),
      DocumentItem(title: "Visa", description: "Vietnam - Multiple Entry", icon: Icons.assignment, color: const Color(0xFF4CAF50)),
      DocumentItem(title: "Bảo hiểm du lịch", description: "Bảo việt - Toàn cầu", icon: Icons.verified_user, color: const Color(0xFFFF9800)),
      DocumentItem(title: "Vé máy bay", description: "Phú Quốc - Sài Gòn", icon: Icons.flight_takeoff, color: const Color(0xFFE91E63)),
    ];

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
                "Hồ sơ của tôi",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nguyễn Văn A", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("vanya.traveler@email.com", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Documents Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hồ sơ & Giấy tờ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Thêm mới",
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    return DocumentCard(doc: documents[index]);
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
