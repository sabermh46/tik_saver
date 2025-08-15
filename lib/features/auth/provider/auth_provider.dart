// lib/features/auth/provider/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      state = AuthState(user: user);
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.sendEmailVerification();
        state = AuthState(user: userCredential.user, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message);
    } catch (e) {
      state = AuthState(isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message);
    } catch (e) {
      state = AuthState(isLoading: false, error: 'An unexpected error occurred.');
    } finally {
      // The authStateChanges listener will update the state automatically on success
      // We only need to set isLoading to false here in case of a non-auth error.
      if (state.isLoading) {
        state = AuthState(isLoading: false);
      }
    }
  }

  Future<void> resetPassword(String email) async {
    state = AuthState(isLoading: true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = AuthState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message);
    } catch (e) {
      state = AuthState(isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());