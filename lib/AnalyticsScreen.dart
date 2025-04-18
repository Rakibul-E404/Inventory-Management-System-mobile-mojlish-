import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashBoard.dart';
import 'StockProviderPage.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalExpense();
  }

  Future<void> _loadTotalExpense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalExpense = prefs.getDouble("totalExpense") ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final Map<String, double> brandData = provider.getBrandSalesData(); // Get product counts by brand
    final double totalIncome = provider.totalIncome;
    final double revenue = totalIncome - _totalExpense; // Calculate Revenue

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Dashboard(
                  role: 'admin',
                  stockItems: [],
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Products Sold from the Brands:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),

            ),
            const SizedBox(height: 16),
            Text(
              'Total Expense: \$${_totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Changed to red to indicate expense
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Income: \$${totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenue: \$${revenue.toStringAsFixed(2)}', // Display Revenue
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: revenue >= 0 ? Colors.green : Colors.red, // Green if positive, Red if negative
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: brandData.isNotEmpty
                  ? PieChart(
                dataMap: brandData, // Display number of products sold by brand
                animationDuration: const Duration(milliseconds: 1800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 2,
                colorList: _getColorList(),
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
                ringStrokeWidth: 32,
                centerText: "Sales",
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: false,
                  showChartValuesOutside: true,
                  decimalPlaces: 0,
                ),
              )
                  : const Center(
                child: Text(
                  'No sales data available.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getColorList() {
    return [
      Colors.indigo.shade400,
      Colors.brown.shade400,
      Colors.green.shade400,
      Colors.yellow.shade600,
      Colors.orange.shade400,
      Colors.purple.shade300,
      Colors.pink.shade400,
      Colors.cyan.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
    ];
  }
}
