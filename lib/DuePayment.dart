import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'StockProviderPage.dart';
import 'productModel.dart';
import 'DashBoard.dart';

class Duepayment extends StatefulWidget {
  const Duepayment({super.key});

  @override
  _DuepaymentState createState() => _DuepaymentState();
}

class _DuepaymentState extends State<Duepayment> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _filterByRole;

  @override
  void initState() {
    super.initState();
    _filterSoldItems();
  }

  void _filterSoldItems() {
    final provider = Provider.of<StockProvider>(context, listen: false);
    provider.filterSoldItems(_startDate, _endDate, _filterByRole);
  }

  void _filterLast7Days() {
    setState(() {
      _startDate = DateTime.now().subtract(Duration(days: 7));
      _endDate = DateTime.now();
      _filterByRole = null;
      _filterSoldItems();
    });
  }

  void _filterToday() {
    setState(() {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _filterByRole = null;
      _filterSoldItems();
    });
  }

  void _filterByRoleFunction(String role) {
    setState(() {
      _filterByRole = role;
      _filterSoldItems();
    });
  }

  Future<void> _addPayment(ProductModel item) async {
    final TextEditingController paymentController = TextEditingController();
    final ValueNotifier<DateTime?> selectedDateNotifier = ValueNotifier<DateTime?>(null);

    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: paymentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Payment Amount'),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<DateTime?>(
                valueListenable: selectedDateNotifier,
                builder: (context, selectedDate, child) {
                  return Text(
                    selectedDate != null
                        ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'
                        : 'No date selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedDate == null ? Colors.red : Colors.black,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  selectedDateNotifier.value = newDate;
                },
                child: ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDateNotifier,
                  builder: (context, selectedDate, child) {
                    return Text(
                      selectedDate == null
                          ? 'Select Payment Date'
                          : DateFormat('yyyy-MM-dd').format(selectedDate),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true && selectedDateNotifier.value != null) {
      final newPayment = paymentController.text;
      final provider = Provider.of<StockProvider>(context, listen: false);

      provider.addPayment(item.barcode, newPayment, DateFormat('yyyy-MM-dd').format(selectedDateNotifier.value!));

      final double duePayment = double.parse(item.ProductSellPrice) -
          (provider.getTotalPayments(item.barcode) + double.parse(item.payment));
      if (duePayment <= 0) {
        provider.updatePaymentStatus(item.barcode, 'Paid');
      }

      setState(() {
        _filterSoldItems();
      });
    }
  }

  void _showItemDetails(ProductModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Details: ${item.name}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                  columns: const [
                    DataColumn(
                        label: Text(
                          'Field',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        )),
                    DataColumn(
                        label: Text(
                          'Value',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        )),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Sold By')),
                      DataCell(Text(item.soldBy)),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Sold Price')),
                      DataCell(Text(item.ProductSellPrice)),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Payment and Date')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showPaymentAndDateDetails(item);
                          },
                        ),
                      ),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Due Payment')),
                      DataCell(Text((double.parse(item.ProductSellPrice) -
                          (double.parse(item.payment) +
                              Provider.of<StockProvider>(context, listen: false)
                                  .getTotalPayments(item.barcode)))
                          .toStringAsFixed(2))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Memo')),
                      DataCell(Text(item.memoNumber)),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Status')),
                      DataCell(Text(item.status ?? 'Pending')),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentAndDateDetails(ProductModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment and Date Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Main Payment: ${item.payment}'),
                const SizedBox(height: 8),
                Text('Payment Dates: ${item.dateTime}'),
                const SizedBox(height: 16),
                Text('Additional Payments:'),
                ...Provider.of<StockProvider>(context, listen: false)
                    .getPayments(item.barcode)
                    .map((payment) => Text('${payment.amount} on ${payment.date}'))
                    .toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    DateTime today = DateTime.now();
    double totalTodayPayments = 0.0;

    for (var item in provider.filteredSoldItems) {
      DateTime itemDate = DateFormat('yyyy-MM-dd').parse(item.dateTime);

      if (itemDate.year == today.year &&
          itemDate.month == today.month &&
          itemDate.day == today.day) {
        double payment = double.parse(item.payment);
        double additionalPayments = provider.getTotalPayments(item.barcode);
        totalTodayPayments += payment + additionalPayments;
      }
    }

    // Filter out items with status 'Paid'
    final filteredItems = provider.filteredSoldItems.where((item) => item.status != 'Paid').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Payment'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Dashboard(role: 'admin', stockItems: []),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'last_7_days':
                  _filterLast7Days();
                  break;
                case 'today':
                  _filterToday();
                  break;
                case 'by_admin':
                  _filterByRoleFunction('admin');
                  break;
                case 'by_moderator':
                  _filterByRoleFunction('moderator');
                  break;
                case 'clear':
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _filterByRole = null;
                    _filterSoldItems();
                  });
                  provider.clearSoldItemFilters();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'last_7_days',
                child: Text('Last 7 Days'),
              ),
              const PopupMenuItem<String>(
                value: 'today',
                child: Text('Today'),
              ),
              const PopupMenuItem<String>(
                value: 'by_admin',
                child: Text('By Admin'),
              ),
              const PopupMenuItem<String>(
                value: 'by_moderator',
                child: Text('By Moderator'),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Payment for Today: \$${totalTodayPayments.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Fixed Header Row
                  Container(
                    color: Colors.grey[200], // Optional: color to distinguish the header
                    child: Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: const {
                        0: FixedColumnWidth(60.0),
                        1: FixedColumnWidth(120.0),
                        2: FixedColumnWidth(100.0),
                        3: FixedColumnWidth(70.0),
                        4: FixedColumnWidth(75.0),
                        5: FixedColumnWidth(120.0),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                          children: [
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Sl No.',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Due Amount',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Memo',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Center(
                                  child: Text(
                                    'Actions',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          columnWidths: const {
                            0: FixedColumnWidth(60.0),
                            1: FixedColumnWidth(120.0),
                            2: FixedColumnWidth(100.0),
                            3: FixedColumnWidth(70.0),
                            4: FixedColumnWidth(75.0),
                            5: FixedColumnWidth(120.0),
                          },
                          children: [
                            for (var item in filteredItems)
                              TableRow(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black, width: 1.0),
                                  ),
                                ),
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          (filteredItems.indexOf(item) + 1).toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(item.name),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          (double.parse(item.ProductSellPrice) -
                                              (double.parse(item.payment) +
                                                  provider.getTotalPayments(item.barcode)))
                                              .toStringAsFixed(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(item.memoNumber),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(item.status ?? 'Pending'),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                _addPayment(item);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.info_outline),
                                              onPressed: () {
                                                _showItemDetails(item);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


