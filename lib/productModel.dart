
import 'dart:io';

class Payment {
  final String amount;
  final String date;

  Payment({
    required this.amount,
    required this.date,
  });
}

class ProductModel {
  final String quantity;
  final String name;
  final String buyingPrice;
  final String sellingPrice;
  final String ProductSellPrice;
  final File? image;
  final String brand;
  final String description;
  final String barcode;
  final String soldBy;
  late final String dateTime;
  final String memoNumber;
  final String IMEInumber;
  late final String payment;
  String? status;
  List<Payment> payments; // New list to store multiple payments

  ProductModel({
    required this.quantity,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.ProductSellPrice,
    this.image,
    required this.brand,
    required this.description,
    required this.barcode,
    this.soldBy = '',
    this.dateTime = '',
    this.memoNumber = '',
    this.IMEInumber = '',
    required this.payment,
    this.status,
    this.payments = const [], // Initialize with an empty list by default
  });

  ProductModel copyWith({
    String? quantity,
    String? name,
    String? buyingPrice,
    String? sellingPrice,
    String? ProductSellPrice,
    File? image,
    String? brand,
    String? description,
    String? barcode,
    String? soldBy,
    String? dateTime,
    String? memoNumber,
    String? IMEInumber,
    String? payment,
    String? status,
    List<Payment>? payments,
  }) {
    return ProductModel(
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      ProductSellPrice: ProductSellPrice ?? this.ProductSellPrice,
      image: image ?? this.image,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      soldBy: soldBy ?? this.soldBy,
      dateTime: dateTime ?? this.dateTime,
      memoNumber: memoNumber ?? this.memoNumber,
      IMEInumber: IMEInumber ?? this.IMEInumber,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      payments: payments ?? this.payments,
    );
  }
}

