import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantGuess {
  final String? name, key;
  final List<String> candidates;
  const MerchantGuess({this.name, this.key, this.candidates = const []});
}

class MerchantExtractor {
  static final _reject = RegExp(
      r'^(tax\s*invoice|invoice|receipt|cash\s*memo|bill\b|gst|fssai|cin\b|pan\b|tel|ph\b|phone|mob|e-?mail|date|time|table|cashier|order|token|kot|welcome|thank)|www\.|\.com|@',
      caseSensitive: false);
  static final _address = RegExp(r'\b(road|rd|street|st|nagar|floor|near|plot|sector|lane|opp)\b', caseSensitive: false);
  static final _gstin = RegExp(r'\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]');
  static final _paidTo = RegExp(r'(?:paid to|sent to)\s*[:\-]?\s*(.+)', caseSensitive: false);

  static String _title(String s) => s.toLowerCase().split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

  static MerchantGuess extract(RecognizedText r) {
    final lines = [for (final b in r.blocks) ...b.lines];
    if (lines.isEmpty) return const MerchantGuess();

    final gstin = _gstin.firstMatch(r.text.toUpperCase().replaceAll(' ', ''))?.group(0);
    final paid = _paidTo.firstMatch(r.text)?.group(1)?.trim();
    final top = lines.map((l) => l.boundingBox.top).reduce(min);
    final bottom = lines.map((l) => l.boundingBox.bottom).reduce(max);
    final span = max(1.0, bottom - top);
    final heights = lines.map((l) => l.boundingBox.height).toList()..sort();
    final median = max(1.0, heights[heights.length ~/ 2]);

    final scored = <String, double>{};
    for (final l in lines) {
      final text = l.text.trim();
      final y = (l.boundingBox.top - top) / span;
      if (y > 0.35 || text.isEmpty || _reject.hasMatch(text)) continue;
      final letters = RegExp('[A-Za-z]').allMatches(text).length;
      if (letters < 3 || letters / text.length < 0.6) continue;
      var s = (l.boundingBox.height / median).clamp(0.5, 3.0) * 2 + (0.35 - y) * 4;
      if (text == text.toUpperCase()) s += 0.5;
      if (_address.hasMatch(text)) s -= 1.5;
      if (text.length > 32) s -= 1;
      scored[_title(text)] = s;
    }
    final ranked = scored.keys.toList()..sort((a, b) => scored[b]!.compareTo(scored[a]!));
    final candidates = ranked.take(3).toList();
    final name = paid ?? (candidates.isEmpty ? null : candidates.first);
    return MerchantGuess(
      name: name,
      candidates: candidates,
      key: gstin ?? name?.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), ''),
    );
  }
}

class MerchantMemory {
  static Future<String?> lookup(String? key) async => key == null
      ? null
      : (await SharedPreferences.getInstance()).getString('merchant_$key');
  static Future<void> remember(String? key, String name) async {
    if (key == null || name.isEmpty) return;
    await (await SharedPreferences.getInstance()).setString('merchant_$key', name);
  }
}

