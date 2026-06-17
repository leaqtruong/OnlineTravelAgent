import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/document_item.dart';
import '../../../providers/profile_provider.dart';

class DocumentCard extends ConsumerWidget {
  final DocumentItem doc;

  const DocumentCard({super.key, required this.doc});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xóa giấy tờ?"),
        content: Text("Xác nhận xóa \"${doc.title}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await ref.read(documentsProvider.notifier).deleteDocument(doc.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? "Đã xóa giấy tờ" : "Xóa thất bại"),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: doc.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(doc.icon, color: doc.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(doc.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: "Xóa",
          ),
        ],
      ),
    );
  }
}
