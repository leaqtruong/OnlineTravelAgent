import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/document_item.dart';
import 'app_state_provider.dart';
import 'api_provider.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.profile ?? const UserProfile(name: 'User', email: '');
  }

  Future<bool> updateProfile({required String name, required String email}) async {
    try {
      final updated = await ref.read(apiProvider).updateProfile(name: name, email: email);
      state = updated;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

class DocumentsNotifier extends Notifier<List<DocumentItem>> {
  @override
  List<DocumentItem> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.documents ?? [];
  }

  Future<bool> addDocument({
    required String title,
    required String description,
    String icon = 'description',
    String color = '#176FF2',
  }) async {
    try {
      final doc = await ref.read(apiProvider).addDocument(
        title: title, description: description, icon: icon, color: color,
      );
      state = [doc, ...state];
      return true;
    } catch (_) {
      return false;
    }
  }
}

final documentsProvider = NotifierProvider<DocumentsNotifier, List<DocumentItem>>(DocumentsNotifier.new);
