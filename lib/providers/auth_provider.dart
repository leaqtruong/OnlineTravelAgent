import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import 'api_provider.dart';
import 'profile_provider.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final UserProfile? user;

  const AuthState({
    this.isLoggedIn = false,
    this.token,
    this.user,
  });

  AuthState copyWith({bool? isLoggedIn, String? token, UserProfile? user}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<String?> login({required String email, required String password}) async {
    try {
      final api = ref.read(apiProvider);
      final data = await api.login(email: email, password: password);
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>? ?? {'name': email, 'email': email});
      final token = data['token']?.toString();

      // Inject token into API Service
      api.token = token;

      state = AuthState(isLoggedIn: true, token: token, user: user);

      // Sync profile provider with the logged-in user data
      ref.read(profileProvider.notifier).updateFromAuth(name: user.name, email: user.email);

      return null; // success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> register({required String name, required String email, required String password}) async {
    try {
      await ref.read(apiProvider).register(name: name, email: email, password: password);
      return null; // success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  void logout() {
    ref.read(apiProvider).token = null;
    state = const AuthState();
  }

  void updateToken(String newToken) {
    ref.read(apiProvider).token = newToken;
    state = state.copyWith(token: newToken);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
