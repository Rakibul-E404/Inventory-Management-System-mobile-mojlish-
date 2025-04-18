import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'StockProviderPage.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  DateTimeRange? customDateRange;
  String? selectedFilter = 'All'; // Set initial filter to "All"

  @override
  void initState() {
    super.initState();
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    stockProvider.filterAll(); // Apply the "All" filter initially
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);

    final totalIncome = stockProvider.totalIncome;
    final formattedTotalIncome = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(totalIncome);

    // Calculate filtered income
    final filteredIncome = stockProvider.filteredTotalIncome;
    final formattedFilteredIncome = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(filteredIncome);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Total Income',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8.0),
                Text(
                  formattedTotalIncome,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (selectedFilter != 'All') ...[
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    '$selectedFilter Income:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    formattedFilteredIncome,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16.0),
            // Filter Dropdown
            DropdownButton<String>(
              hint: const Text('Select Filter'),
              value: selectedFilter,
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  setState(() {
                    selectedFilter = newValue;
                  });

                  switch (newValue) {
                    case 'All':
                      stockProvider.filterAll();
                      break;
                    case 'Today':
                      stockProvider.filterToday();
                      break;
                    case 'Last 7 Days':
                      stockProvider.filterLast7Days();
                      break;
                    case 'This Month':
                      stockProvider.filterThisMonth();
                      break;
                    case 'Custom':
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          customDateRange = picked;
                        });
                        stockProvider.filterCustom(picked.start, picked.end);
                      }
                      break;
                    case 'Clear Filter':
                      stockProvider.clearFilter();
                      setState(() {
                        customDateRange = null;
                        selectedFilter = 'All'; // Reset to "All"
                      });
                      break;
                  }
                }
              },
              items: <String>[
                'All',
                'Today',
                'Last 7 Days',
                'This Month',
                'Custom',
                'Clear Filter'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            // List of sold products as a table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('No.')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Selling Price')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: stockProvider.filteredSoldItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')), // Serial number
                      DataCell(Text(item.name)),
                      DataCell(Text('\$${item.ProductSellPrice}')),
                      DataCell(Text(item.dateTime)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
