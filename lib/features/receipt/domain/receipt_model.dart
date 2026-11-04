import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'receipt_model.freezed.dart';
part 'receipt_model.g.dart';

@freezed
class ReceiptModel with _$ReceiptModel {
  const factory ReceiptModel({
    required String id,
    required String merchant,
    required String category,
    required DateTime purchaseDate,
    required String currency,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required String paymentMethod,
    required String invoiceNumber,
    required List<ProductModel> products,
    String? imageUrl,
    String? ocrText,
    int? warrantyMonths,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);
}
