import '../../domain/entities/b2b_order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/payment_status.dart';
import 'order_item_model.dart';

class B2BOrderModel extends B2BOrder {
  const B2BOrderModel({
    required super.id,
    required super.reference,
    required super.wholesalerId,
    required super.wholesalerName,
    required super.retailerId,
    required super.retailerName,
    required super.status,
    required super.statusName,
    required super.paymentStatus,
    required super.paymentStatusName,
    required super.items,
    required super.itemCount,
    required super.subtotal,
    super.discountAmount,
    required super.totalAmount,
    super.amountPaid,
    required super.amountDue,
    super.useCredit,
    super.notes,
    super.deliveryAddress,
    super.expectedDeliveryDate,
    required super.createdAt,
    super.confirmedAt,
    super.shippedAt,
    super.deliveredAt,
    super.cancelledAt,
    super.cancellationReason,
  });

  factory B2BOrderModel.fromJson(Map<String, dynamic> json) {
    return B2BOrderModel(
      id: json['id'] as String,
      reference: json['reference'] as String,
      wholesalerId: json['wholesalerId'] as String,
      wholesalerName: json['wholesalerName'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      statusName: json['statusName'] as String,
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String),
      paymentStatusName: json['paymentStatusName'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      itemCount: json['itemCount'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      amountDue: (json['amountDue'] as num?)?.toDouble() ?? 0,
      useCredit: json['useCredit'] as bool? ?? false,
      notes: json['notes'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'wholesalerId': wholesalerId,
      'wholesalerName': wholesalerName,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'status': status.name.toUpperCase(),
      'statusName': statusName,
      'paymentStatus': paymentStatus.name.toUpperCase(),
      'paymentStatusName': paymentStatusName,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'itemCount': itemCount,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'useCredit': useCredit,
      'notes': notes,
      'deliveryAddress': deliveryAddress,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  B2BOrder toEntity() => B2BOrder(
        id: id,
        reference: reference,
        wholesalerId: wholesalerId,
        wholesalerName: wholesalerName,
        retailerId: retailerId,
        retailerName: retailerName,
        status: status,
        statusName: statusName,
        paymentStatus: paymentStatus,
        paymentStatusName: paymentStatusName,
        items: items,
        itemCount: itemCount,
        subtotal: subtotal,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        amountDue: amountDue,
        useCredit: useCredit,
        notes: notes,
        deliveryAddress: deliveryAddress,
        expectedDeliveryDate: expectedDeliveryDate,
        createdAt: createdAt,
        confirmedAt: confirmedAt,
        shippedAt: shippedAt,
        deliveredAt: deliveredAt,
        cancelledAt: cancelledAt,
        cancellationReason: cancellationReason,
      );
}
