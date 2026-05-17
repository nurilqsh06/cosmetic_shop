import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetic_shop/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(null) {
    _checkAuthState();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      print('Auth state changed: ${user?.email ?? user?.uid}');
      if (user != null) {
        final appUser = AppUser(
          id: user.uid,
          email: user.email ?? 'user@example.com',
          name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          createdAt: DateTime.now(),
        );
        state = appUser;
        print('User signed in: ${appUser.email}');
      } else {
        state = null;
        print('User signed out');
      }
    });
  }

  Future<String> signUp(String email, String password, String name) async {
    try {
      print('Attempting sign up for: $email');

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user?.updateDisplayName(name.trim());
      await userCredential.user?.reload();

      print('User created: ${userCredential.user?.uid}');

      final newUser = AppUser(
        id: userCredential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

      state = newUser;
      return 'Success';
    } on FirebaseAuthException catch (e) {
      print('Auth error: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      }
      return e.message ?? 'Sign up failed';
    } catch (e) {
      print('Error: $e');
      return e.toString();
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      print('Attempting sign in for: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User signed in: ${userCredential.user?.uid}');

      final appUser = AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? email.trim(),
        name: userCredential.user!.displayName ?? email.trim().split('@')[0],
        createdAt: DateTime.now(),
      );

      state = appUser;
      return 'Success';
    } on FirebaseAuthException catch (e) {
      print('Auth error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      }
      return e.message ?? 'Sign in failed';
    } catch (e) {
      print('Error: $e');
      return e.toString();
    }
  }

  Future<String> signInAnonymously() async {
    try {
      print('Attempting anonymous sign in');

      UserCredential userCredential = await _auth.signInAnonymously();

      print('Anonymous user created: ${userCredential.user?.uid}');

      final newUser = AppUser(
        id: userCredential.user!.uid,
        email: 'guest@user.com',
        name: 'Guest User',
        createdAt: DateTime.now(),
      );

      state = newUser;
      return 'Success';
    } on FirebaseAuthException catch (e) {
      print('Auth error: ${e.code} - ${e.message}');
      return e.message ?? 'Guest sign in failed';
    } catch (e) {
      print('Error: $e');
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

final authStateProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});