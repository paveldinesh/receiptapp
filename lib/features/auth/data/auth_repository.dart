import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String name);
  Future<void> signOut();
  UserModel? get currentUser;
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _firebaseAuth;
  final bool _isFirebaseAvailable;
  
  // Local fallback mock state
  UserModel? _mockUser;
  
  FirebaseAuthRepository(this._firebaseAuth, this._isFirebaseAvailable) {
    if (_isFirebaseAvailable && _firebaseAuth == null) {
      throw Exception("FirebaseAuth is required when Firebase is available.");
    }
    if (!_isFirebaseAvailable) {
      _loadMockSession();
    }
  }

  Future<void> _loadMockSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('mock_user_email');
    final name = prefs.getString('mock_user_name');
    if (email != null) {
      _mockUser = UserModel(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: name ?? email.split('@').first,
      );
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (_isFirebaseAvailable) {
      return _firebaseAuth!.authStateChanges().map((user) {
        if (user == null) return null;
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      });
    } else {
      // Local fallback stream
      return Stream.value(_mockUser);
    }
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    if (_isFirebaseAvailable) {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
        );
      }
      return null;
    } else {
      // Local mock sign in
      final username = email.split('@').first;
      final displayName = username.isNotEmpty ? username[0].toUpperCase() + username.substring(1) : 'User';
      _mockUser = UserModel(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: displayName,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_email', email);
      await prefs.setString('mock_user_name', displayName);
      return _mockUser;
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    if (_isFirebaseAvailable) {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: name,
        );
      }
      return null;
    } else {
      // Local mock sign up
      _mockUser = UserModel(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: name,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_email', email);
      await prefs.setString('mock_user_name', name);
      return _mockUser;
    }
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      await _firebaseAuth!.signOut();
    } else {
      _mockUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user_email');
      await prefs.remove('mock_user_name');
    }
  }

  @override
  UserModel? get currentUser {
    if (_isFirebaseAvailable) {
      final user = _firebaseAuth!.currentUser;
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } else {
      return _mockUser;
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  final isAvailable = ref.watch(firebaseAvailableProvider);
  if (isAvailable) {
    return FirebaseAuth.instance;
  }
  return null;
});

final firebaseAvailableProvider = StateProvider<bool>((ref) {
  return false; 
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final isAvailable = ref.watch(firebaseAvailableProvider);
  return FirebaseAuthRepository(auth, isAvailable);
});

final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});
