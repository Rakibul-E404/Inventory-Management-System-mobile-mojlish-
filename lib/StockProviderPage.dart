
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_mojlish/productModel.dart';

class StockProvider with ChangeNotifier {
  final List<ProductModel> _stockItems = [];
  final List<ProductModel> _soldItems = [];
  final List<ProductModel> _filteredSoldItems = [];
  List<String> suggestedBrands = [];
  List<double> _additionalCashInputs = []; // List to store additional cash inputs

  List<ProductModel> get stockItems => _stockItems;
  List<ProductModel> get soldItems => _filteredSoldItems.isNotEmpty ? _filteredSoldItems : _soldItems;
  List<ProductModel> get filteredSoldItems => _filteredSoldItems;

  StockProvider() {
    _filteredSoldItems.addAll(_soldItems);
  }

  double get totalIncome {
    double total = 0.0;
    for (var item in _soldItems) {
      if (item.status == 'paid') {
        total += double.parse(item.payment); // Use payment value for paid items
      } else {
        total += double.parse(item.ProductSellPrice); // Use full sell price for unpaid items
      }
    }
    return total;
  }

  double get filteredTotalIncome {
    double total = 0.0;
    for (var item in _filteredSoldItems) {
      if (item.status == 'paid') {
        total += double.parse(item.payment); // Use payment value for paid items
      } else {
        total += double.parse(item.ProductSellPrice); // Use full sell price for unpaid items
      }
    }
    return total;
  }

  void saveUpdatedPayment(String itemId, String newPaymentValue) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      _soldItems[itemIndex] = _soldItems[itemIndex].copyWith(payment: newPaymentValue);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void filterAll() {
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems);
    notifyListeners();
  }

  void filterToday() {
    DateTime now = DateTime.now();
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems.where((item) => isSameDay(DateFormat('dd-MM-yyyy – hh:mm').parse(item.dateTime), now)));
    notifyListeners();
  }

  void filterLast7Days() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems.where((item) {
      final itemDate = DateFormat('dd-MM-yyyy – hh:mm').parse(item.dateTime);
      return itemDate.isAfter(weekAgo) && itemDate.isBefore(now);
    }));
    notifyListeners();
  }

  void filterThisMonth() {
    DateTime now = DateTime.now();
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems.where((item) {
      final itemDate = DateFormat('yyyy-MM-dd – hh:mm').parse(item.dateTime);
      return itemDate.month == now.month && itemDate.year == now.year;
    }));
    notifyListeners();
  }

  void filterCustom(DateTime startDate, DateTime endDate) {
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems.where((item) {
      final itemDate = DateFormat('yyyy-MM-dd – hh:mm').parse(item.dateTime);
      return itemDate.isAfter(startDate) && itemDate.isBefore(endDate);
    }));
    notifyListeners();
  }

  void clearFilter() {
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems);
    notifyListeners();
  }

  void clearSoldItemFilters() {
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems);
    notifyListeners();
  }

  void filterSoldItems(DateTime? startDate, DateTime? endDate, String? role) {
    _filteredSoldItems.clear();
    _filteredSoldItems.addAll(_soldItems.where((item) {
      final itemDate = DateFormat('yyyy-MM-dd – hh:mm').parse(item.dateTime);
      final withinDateRange =
          (startDate == null || itemDate.isAfter(startDate)) &&
              (endDate == null || itemDate.isBefore(endDate));
      final matchesRole = role == null || item.soldBy == role;
      return withinDateRange && matchesRole;
    }));
    notifyListeners();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void updatePaymentValue(String itemId, String newPaymentValue) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      _soldItems[itemIndex].payment = newPaymentValue;
      _soldItems[itemIndex].status = 'Pending'; // Reset status to 'Pending' if payment is updated
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void addOrEditItem(ProductModel product, int? index) {
    if (index == null) {
      _stockItems.add(product);
    } else {
      _stockItems[index] = product;
    }
    notifyListeners();
  }

  void deleteItem(int index) {
    _stockItems.removeAt(index);
    notifyListeners();
  }

  void sellProduct(int index, String quantity, String sellingPrice, String role, String memoNumber, String IMEInumber, String payment) {
    final product = _stockItems[index];
    _stockItems.removeAt(index); // Remove item from stock after sale

    _soldItems.add(ProductModel(
      name: product.name,
      buyingPrice: product.buyingPrice,
      sellingPrice: product.sellingPrice,
      ProductSellPrice: sellingPrice,
      image: product.image,
      brand: product.brand,
      description: product.description,
      barcode: product.barcode,
      soldBy: role,
      dateTime: DateFormat('yyyy-MM-dd – hh:mm').format(DateTime.now()),
      memoNumber: memoNumber,
      IMEInumber: product.IMEInumber,
      payment: payment,
      status: 'Pending',
      quantity: '', // Default status
    ));

    notifyListeners();
  }

  bool isBarcodeUnique(String barcode, int? index) {
    for (int i = 0; i < _stockItems.length; i++) {
      if (_stockItems[i].barcode == barcode && i != index) {
        return false;
      }
    }
    return true;
  }

  ProductModel? findByBarcode(String barcode) {
    try {
      return _stockItems.firstWhere((item) => item.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  void addBrand(String brandName) {
    if (!suggestedBrands.contains(brandName)) {
      suggestedBrands.add(brandName);
      notifyListeners();
    }
  }

  void removeBrand(String brandName) {
    suggestedBrands.remove(brandName);
    notifyListeners();
  }

  Map<String, double> getBrandSalesData() {
    Map<String, double> brandSalesData = {};

    for (var item in _soldItems) {
      if (brandSalesData.containsKey(item.brand)) {
        // Update count data
        brandSalesData[item.brand] = (brandSalesData[item.brand] ?? 0) + 1;
      } else {
        // Initialize count data
        brandSalesData[item.brand] = 1;
      }
    }

    return brandSalesData;
  }

  double calculateTotalProfit() {
    double totalProfit = 0.0;
    for (var item in _soldItems) {
      double buyingPrice = double.parse(item.buyingPrice);
      double sellingPrice = double.parse(item.ProductSellPrice);
      double profit = sellingPrice - buyingPrice;
      totalProfit += profit;
    }
    return totalProfit;
  }

  void updatePaymentStatus(String itemId, String status) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      _soldItems[itemIndex].status = status;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  double getDailyTotalPayment() {
    double totalPayment = 0.0;
    DateTime today = DateTime.now();

    for (var item in _soldItems) {
      final itemDate = DateFormat('yyyy-MM-dd – hh:mm').parse(item.dateTime);
      if (isSameDay(itemDate, today)) {
        totalPayment += double.parse(item.payment);
      }
    }

    return totalPayment;
  }

  void addCashInput(double cashInput) {
    _additionalCashInputs.add(cashInput);
    notifyListeners();
  }

  double get totalAdditionalCash {
    return _additionalCashInputs.fold(0.0, (sum, cash) => sum + cash);
  }

  void updatePaymentDate(String itemId, String newDate) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      _soldItems[itemIndex] = _soldItems[itemIndex].copyWith(dateTime: newDate);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void addPaymentToProduct(String itemId, String amount, String date) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      List<Payment> updatedPayments = List.from(_soldItems[itemIndex].payments)
        ..add(Payment(amount: amount, date: date));

      _soldItems[itemIndex] = _soldItems[itemIndex].copyWith(payments: updatedPayments);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Method to add a payment to a product
  void addPayment(String itemId, String amount, String date) {
    final itemIndex = _soldItems.indexWhere((item) => item.barcode == itemId); // Assuming barcode is unique
    if (itemIndex != -1) {
      List<Payment> updatedPayments = List.from(_soldItems[itemIndex].payments)
        ..add(Payment(amount: amount, date: date));

      _soldItems[itemIndex] = _soldItems[itemIndex].copyWith(payments: updatedPayments);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Method to get the total amount of payments made for a specific product
  double getTotalPayments(String itemId) {
    final item = _soldItems.firstWhere((item) => item.barcode == itemId);
    if (item != null) {
      return item.payments.fold(0.0, (sum, payment) => sum + double.parse(payment.amount));
    }
    return 0.0;
  }

  // Method to retrieve the list of payments for a specific product
  List<Payment> getPayments(String itemId) {
    final item = _soldItems.firstWhere((item) => item.barcode == itemId);
    if (item != null) {
      return item.payments;
    }
    return [];
  }

  // Method to get all sold items
  List<ProductModel> getSoldItems() {
    return _soldItems;
  }

  // Method to add sold items (example logic)
  void addSoldItem(ProductModel item) {
    _soldItems.add(item);
    notifyListeners();
  }



  List<Map<String, String>> expenses = [];
  double getLiveExpense() {
    // Calculate the total expenses for today or all-time depending on your use case
    return expenses.fold(0.0, (sum, expense) => sum + double.parse(expense['amount']!));
  }

  List<Map<String, String>> getAllExpenses() {
    return expenses;
  }
}
