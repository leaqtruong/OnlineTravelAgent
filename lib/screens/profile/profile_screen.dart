import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/document_item.dart';
import '../../models/user_profile.dart';
import '../../providers/travel_provider.dart';
import 'widgets/document_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final provider = context.read<TravelProvider>();
    final nameController = TextEditingController(text: provider.profile.name);
    final emailController = TextEditingController(text: provider.profile.email);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Chỉnh sửa hồ sơ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Họ tên"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final ok = await provider.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? "Cập nhật hồ sơ thành công" : "Cập nhật hồ sơ thất bại"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _showAddDocumentDialog(BuildContext context) async {
    final provider = context.read<TravelProvider>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Thêm giấy tờ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Tiêu đề"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Mô tả"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok =
        await provider.addDocument(title: title, description: description);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Đã thêm giấy tờ" : "Thêm giấy tờ thất bại"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select<TravelProvider, UserProfile>((p) => p.profile);
    final documents = context.select<TravelProvider, List<DocumentItem>>((p) => p.documents);

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
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile.email,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hồ sơ & Giấy tờ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _showAddDocumentDialog(context),
                    child: const Text(
                      "Thêm mới",
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: documents.isEmpty
                    ? const Center(
                        child: Text(
                          "Chưa có giấy tờ nào",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: documents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
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
