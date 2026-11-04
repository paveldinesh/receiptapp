// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptModelImpl _$$ReceiptModelImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptModelImpl(
      id: json['id'] as String,
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      currency: json['currency'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      ocrText: json['ocrText'] as String?,
      warrantyMonths: (json['warrantyMonths'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$ReceiptModelImplToJson(_$ReceiptModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchant': instance.merchant,
      'category': instance.category,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'currency': instance.currency,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'invoiceNumber': instance.invoiceNumber,
      'products': instance.products,
      'imageUrl': instance.imageUrl,
      'ocrText': instance.ocrText,
      'warrantyMonths': instance.warrantyMonths,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
    };
