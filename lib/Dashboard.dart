
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_mojlish/DuePayment.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'AnalyticsScreen.dart';
import 'CashScreen.dart';
import 'ExpenseScreen.dart';
import 'IncomeScreen.dart';
import 'Login.dart';
import 'ModeratorsProfileScreen.dart';
import 'ProfilePageScreen.dart';
import 'SoldItemScreen.dart';
import 'StockProviderPage.dart';
import 'StockScreenPage.dart';

class Dashboard extends StatefulWidget {
  final String role;
  final double totalExpense;

  const Dashboard({
    required this.role,
    this.totalExpense = 0.0,
    super.key,
    required List stockItems
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _totalTodayPayments = 0.0;
  double _totalTodayExpenses = 0.0;

  double totalExpensePrefValue = 0.0;

  double get totalTodayPayments => _totalTodayPayments;
  double get totalTodayExpenses => _totalTodayExpenses;

  Future<void> getTotalExpense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    totalExpensePrefValue = prefs.getDouble("totalExpense") ?? 0.0;
    setState(() {});
  }

  @override
  void initState() {
    getTotalExpense();
    _fetchTodayPaymentsAndExpenses(); // Fetch today's payments and expenses
    super.initState();
  }

  void _fetchTodayPaymentsAndExpenses() {
    // Replace these with your actual logic to calculate the total payments and expenses
    setState(() {
      _totalTodayPayments = totalTodayPayments; // Example value
      _totalTodayExpenses = totalTodayExpenses; // Example value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xffF7D786),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        color: const Color(0xffffffff),
        child: Consumer<StockProvider>(
          builder: (context, stockProvider, child) {
            double totalIncome = stockProvider.totalIncome;
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockScreen(role: widget.role),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.cube_box_fill,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Stock",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.role == 'moderator')
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StockScreen(role: widget.role),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff4bbe9d),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.role == "admin")
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SoldItemScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.cart_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Sold Items",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.role == "admin")
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => IncomeScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.moneyBillTrendUp,
                              color: Colors.white,
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Income\nTK: ${totalIncome.toStringAsFixed(1)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.role == 'admin')
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExpenseScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.moneyBillWave,
                              color: Colors.white,
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Expense\nTK: $totalExpensePrefValue",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.role == 'admin')
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.graph_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Analytics",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.role == "admin")
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CashScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff806107),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.money_dollar_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Cash",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.role == 'admin')
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ModeratorsProfilePage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.person_2_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Moderators",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Duepayment(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.timer_fill,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Due",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
