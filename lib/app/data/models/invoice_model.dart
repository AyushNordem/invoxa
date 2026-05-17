import 'package:cloud_firestore/cloud_firestore.dart';

import 'business_model.dart';
import 'customer_model.dart';

class InvoiceModel {
  final String? id;
  final String? userId;
  final String? invoiceNumber;
  final DateTime? date;
  final DateTime? dueDate;
  final String? status; // 'Paid', 'Pending', 'Draft'
  final String currency;

  // Snapshots for persistence
  final BusinessModel? sellerDetails;
  final CustomerModel? buyerDetails;
  final List<InvoiceItem>? items;

  // Totals
  final double subTotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;

  // Tax Flags
  final bool hasCGST;
  final bool hasSGST;
  final bool hasIGST;
  final double taxPercentage;

  final String? notes;
  final String? pdfUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceModel({
    this.id,
    this.userId,
    this.invoiceNumber,
    this.date,
    this.dueDate,
    this.status = 'Pending',
    this.currency = '₹',
    this.sellerDetails,
    this.buyerDetails,
    this.items,
    this.subTotal = 0.0,
    this.discountTotal = 0.0,
    this.taxTotal = 0.0,
    this.grandTotal = 0.0,
    this.hasCGST = false,
    this.hasSGST = false,
    this.hasIGST = false,
    this.taxPercentage = 0.0,
    this.notes,
    this.pdfUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return InvoiceModel(
      id: id,
      userId: map['userId'],
      invoiceNumber: map['invoiceNumber'],
      date: (map['date'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'Pending',
      currency: map['currency']?.toString() ?? '₹',
      sellerDetails: map['sellerDetails'] != null ? BusinessModel.fromMap(map['sellerDetails']) : null,
      buyerDetails: map['buyerDetails'] != null ? CustomerModel.fromMap(map['buyerDetails']) : null,
      items: (map['items'] as List?)?.map((i) => InvoiceItem.fromMap(i)).toList(),
      subTotal: (map['subTotal'] ?? 0.0).toDouble(),
      discountTotal: (map['discountTotal'] ?? 0.0).toDouble(),
      taxTotal: (map['taxTotal'] ?? 0.0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0.0).toDouble(),
      hasCGST: map['hasCGST'] ?? false,
      hasSGST: map['hasSGST'] ?? false,
      hasIGST: map['hasIGST'] ?? false,
      taxPercentage: (map['taxPercentage'] ?? 0.0).toDouble(),
      notes: map['notes'],
      pdfUrl: map['pdfUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'invoiceNumber': invoiceNumber,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status,
      'currency': currency,
      'sellerDetails': sellerDetails?.toMap(),
      'buyerDetails': buyerDetails?.toMap(),
      'items': items?.map((i) => i.toMap()).toList(),
      'subTotal': subTotal,
      'discountTotal': discountTotal,
      'taxTotal': taxTotal,
      'grandTotal': grandTotal,
      'hasCGST': hasCGST,
      'hasSGST': hasSGST,
      'hasIGST': hasIGST,
      'taxPercentage': taxPercentage,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? userId,
    String? invoiceNumber,
    DateTime? date,
    DateTime? dueDate,
    String? status,
    String? currency,
    BusinessModel? sellerDetails,
    CustomerModel? buyerDetails,
    List<InvoiceItem>? items,
    double? subTotal,
    double? discountTotal,
    double? taxTotal,
    double? grandTotal,
    bool? hasCGST,
    bool? hasSGST,
    bool? hasIGST,
    double? taxPercentage,
    String? notes,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      sellerDetails: sellerDetails ?? this.sellerDetails,
      buyerDetails: buyerDetails ?? this.buyerDetails,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      hasCGST: hasCGST ?? this.hasCGST,
      hasSGST: hasSGST ?? this.hasSGST,
      hasIGST: hasIGST ?? this.hasIGST,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InvoiceItem {
  final String? name;
  final String? description;
  final double rate;
  final double quantity;
  final String? unit;
  final double discount;
  final String? hsnCode;
  final double amount;

  InvoiceItem({this.name, this.description, this.rate = 0.0, this.quantity = 1.0, this.unit = 'PCS', this.discount = 0.0, this.hsnCode, this.amount = 0.0});

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(name: map['name'], description: map['description'], rate: (map['rate'] ?? 0.0).toDouble(), quantity: (map['quantity'] ?? 0.0).toDouble(), unit: map['unit'], discount: (map['discount'] ?? 0.0).toDouble(), hsnCode: map['hsnCode'], amount: (map['amount'] ?? 0.0).toDouble());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'rate': rate, 'quantity': quantity, 'unit': unit, 'discount': discount, 'hsnCode': hsnCode, 'amount': amount};
  }
}
