/// A single line-item extracted from a receipt, used only in the preview/
/// confirmation screen's local state.  Intentionally a plain Dart class —
/// no freezed / code-gen required because it never persists directly to the
/// data layer.  Conversion to the existing [ProductModel] map happens via
/// [toProductMap] at save time.
class LineItemModel {
  final String name;
  final int quantity;
  final double rate; // unit price
  final double amount; // line total (qty × rate, may be overridden by user)

  const LineItemModel({
    required this.name,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  LineItemModel copyWith({
    String? name,
    int? quantity,
    double? rate,
    double? amount,
  }) {
    return LineItemModel(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  /// Converts to the map format expected by [ReceiptController.saveReceipt]
  /// which ultimately feeds into [ProductModel.fromJson].
  Map<String, dynamic> toProductMap() => {
        'name': name,
        'quantity': quantity,
        'price': amount, // price stores the line-total in ProductModel
      };

  /// Build from a Gemini-returned [line_items] map entry.
  factory LineItemModel.fromGeminiMap(Map<String, dynamic> m) {
    final qty = (m['quantity'] as num?)?.toInt() ?? 1;
    final rate = (m['rate'] as num?)?.toDouble() ?? 0.0;
    final amount = (m['amount'] as num?)?.toDouble() ?? (qty * rate);
    return LineItemModel(
      name: (m['name'] as String?)?.trim() ?? '',
      quantity: qty,
      rate: rate,
      amount: amount,
    );
  }

  /// Build from the legacy [products] map entry so the preview screen can
  /// display old-style parsed data in the new Items section.
  factory LineItemModel.fromProductMap(Map<String, dynamic> m) {
    final qty = (m['quantity'] as num?)?.toInt() ?? 1;
    final price = (m['price'] as num?)?.toDouble() ?? 0.0;
    return LineItemModel(
      name: (m['name'] as String?)?.trim() ?? '',
      quantity: qty,
      rate: price,
      amount: price * qty,
    );
  }
}
