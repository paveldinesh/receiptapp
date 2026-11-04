import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/data/auth_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    isFirebaseAvailable = true;
    debugPrint('Firebase connected successfully.');
  } catch (e) {
    debugPrint('Firebase not configured. Using local fallback store. ($e)');
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWith((ref) => isFirebaseAvailable),
      ],
      child: const ReceiptVaultApp(),
    ),
  );
}
