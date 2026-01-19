import 'order_item.dart';
import 'order_status.dart';
import 'payment_status.dart';

class B2BOrder {
  final String id;
  final String reference;
  final String wholesalerId;
  final String wholesalerName;
  final String retailerId;
  final String retailerName;
  final OrderStatus status;
  final String statusName;
  final PaymentStatus paymentStatus;
  final String paymentStatusName;
  final List<OrderItem> items;
  final int itemCount;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final double amountDue;
  final bool useCredit;
  final String? notes;
  final String? deliveryAddress;
  final DateTime? expectedDeliveryDate;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const B2BOrder({
    required this.id,
    required this.reference,
    required this.wholesalerId,
    required this.wholesalerName,
    required this.retailerId,
    required this.retailerName,
    required this.status,
    required this.statusName,
    required this.paymentStatus,
    required this.paymentStatusName,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    this.discountAmount = 0,
    required this.totalAmount,
    this.amountPaid = 0,
    required this.amountDue,
    this.useCredit = false,
    this.notes,
    this.deliveryAddress,
    this.expectedDeliveryDate,
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  B2BOrder copyWith({
    String? id,
    String? reference,
    String? wholesalerId,
    String? wholesalerName,
    String? retailerId,
    String? retailerName,
    OrderStatus? status,
    String? statusName,
    PaymentStatus? paymentStatus,
    String? paymentStatusName,
    List<OrderItem>? items,
    int? itemCount,
    double? subtotal,
    double? discountAmount,
    double? totalAmount,
    double? amountPaid,
    double? amountDue,
    bool? useCredit,
    String? notes,
    String? deliveryAddress,
    DateTime? expectedDeliveryDate,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return B2BOrder(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      wholesalerId: wholesalerId ?? this.wholesalerId,
      wholesalerName: wholesalerName ?? this.wholesalerName,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentStatusName: paymentStatusName ?? this.paymentStatusName,
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      useCredit: useCredit ?? this.useCredit,
      notes: notes ?? this.notes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
