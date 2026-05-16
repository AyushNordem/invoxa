import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String? id;
  final String? userId;
  final String? invoiceNumber;
  final DateTime? date;
  final DateTime? dueDate;
  final String? customerId;
  final String? customerName;
  final List<InvoiceItem>? items;
  final double? subTotal;
  final double? taxAmount;
  final double? totalAmount;
  final String? status; // 'Paid', 'Pending', 'Overdue'
  final String? notes;
  final DateTime? createdAt;

  InvoiceModel({
    this.id,
    this.userId,
    this.invoiceNumber,
    this.date,
    this.dueDate,
    this.customerId,
    this.customerName,
    this.items,
    this.subTotal,
    this.taxAmount,
    this.totalAmount,
    this.status,
    this.notes,
    this.createdAt,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return InvoiceModel(
      id: id,
      userId: map['userId'],
      invoiceNumber: map['invoiceNumber'],
      date: (map['date'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      customerId: map['customerId'],
      customerName: map['customerName'],
      items: (map['items'] as List?)?.map((i) => InvoiceItem.fromMap(i)).toList(),
      subTotal: map['subTotal']?.toDouble(),
      taxAmount: map['taxAmount']?.toDouble(),
      totalAmount: map['totalAmount']?.toDouble(),
      status: map['status'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'invoiceNumber': invoiceNumber,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'customerId': customerId,
      'customerName': customerName,
      'items': items?.map((i) => i.toMap()).toList(),
      'subTotal': subTotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class InvoiceItem {
  final String? description;
  final double? quantity;
  final double? rate;
  final double? amount;

  InvoiceItem({this.description, this.quantity, this.rate, this.amount});

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map['description'],
      quantity: map['quantity']?.toDouble(),
      rate: map['rate']?.toDouble(),
      amount: map['amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }
}
