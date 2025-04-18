// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'ExpenseScreen.dart';
// import 'StockProviderPage.dart';
//
// class CashScreen extends StatefulWidget {
//
//   @override
//   State<CashScreen> createState() => _CashScreenState();
// }
//
// class _CashScreenState extends State<CashScreen> {
//
//   double todayExpense = 0;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     _loadNotes();
//     super.initState();
//   }
//   final String _noteKey = 'user_notes';
//   List<Note> _notes = [];
//   Future<void> _loadNotes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _notes = (prefs.getStringList(_noteKey) ?? []).map((note) {
//         final parts = note.split(';');
//         return Note(
//           expense: parts[0],
//           text: parts[1],
//           dateTime: DateTime.parse(parts[2]),
//         );
//       }).toList();
//
//     });
//     _calculateTodayTotalExpense();
//   }
//
//
//   void _calculateTodayTotalExpense() {
//
//     DateTime now = DateTime.now();
//     double total = 0.0;
//     for (var note in _notes) {
//       if (note.dateTime.day == now.day &&
//           note.dateTime.month == now.month &&
//           note.dateTime.year == now.year) {
//         total += double.tryParse(note.expense) ?? 0.0;
//       }
//     }
//     setState(() {
//       todayExpense = total;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<StockProvider>(context);
//
//     DateTime today = DateTime.now();
//     double totalTodayPayments = 0.0;
//
//     for (var item in provider.filteredSoldItems) {
//       DateTime itemDate = DateFormat('yyyy-MM-dd').parse(item.dateTime);
//
//       if (itemDate.year == today.year &&
//           itemDate.month == today.month &&
//           itemDate.day == today.day) {
//         double payment = double.parse(item.payment);
//         double additionalPayments = provider.getTotalPayments(item.barcode);
//         totalTodayPayments += payment + additionalPayments;
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cash'),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_outlined),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Total Payments Today',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'TK: ${totalTodayPayments.toStringAsFixed(2)}____${todayExpense}',
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


///
///
///
///
/// ------------upper code is totally ok but not fully
///





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ExpenseScreen.dart';
import 'StockProviderPage.dart';

class CashScreen extends StatefulWidget {
  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  double todayExpense = 0;
  double handCash = 0;
  final TextEditingController _handCashController = TextEditingController();

  final String _handCashKey = 'hand_cash';
  final String _noteKey = 'user_notes';
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadHandCash();
    _loadNotes();
    _refreshData(); // Trigger data refresh
  }

  Future<void> _loadHandCash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      handCash = prefs.getDouble(_handCashKey) ?? 0.0;
    });
  }

  Future<void> _saveHandCash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double newHandCash = double.tryParse(_handCashController.text) ?? 0.0;
    setState(() {
      handCash += newHandCash;
    });
    await prefs.setDouble(_handCashKey, handCash);
  }

  Future<void> _resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      handCash = 0;
      todayExpense = 0;
      _handCashController.clear();
    });
    await prefs.setDouble(_handCashKey, handCash);
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = (prefs.getStringList(_noteKey) ?? []).map((note) {
        final parts = note.split(';');
        return Note(
          expense: parts[0],
          text: parts[1],
          dateTime: DateTime.parse(parts[2]),
        );
      }).toList();
    });
    _calculateTodayTotalExpense();
  }

  void _calculateTodayTotalExpense() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var note in _notes) {
      if (note.dateTime.day == now.day &&
          note.dateTime.month == now.month &&
          note.dateTime.year == now.year) {
        total += double.tryParse(note.expense) ?? 0.0;
      }
    }
    setState(() {
      todayExpense = total;
    });
  }

  void _refreshData() {
    final provider = Provider.of<StockProvider>(context, listen: false);
    provider.filterSoldItems(null, null, null); // Refresh the filtered items
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Confirmation'),
          content: Text('Are you sure you want to reset all values to zero? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text('Reset'),
            //   onPressed: () async {
            //     Navigator.of(context).pop(); // Close the dialog
            //     await _resetData(); // Perform the reset
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('Data Reset!')),
            //     );
            //   },
            // ),
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

    double totalCash = handCash + totalTodayPayments - todayExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          IconButton(onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            await _resetData(); // Perform the reset
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data Reset!')),
            );
          }, icon: Icon(Icons.restart_alt,color: Colors.red,))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _handCashController,
              decoration: InputDecoration(
                labelText: 'Enter Hand Cash',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _saveHandCash();
                _handCashController.clear(); // Clear the input field after saving
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hand Cash Saved!')),
                );
              },
              child: Text('Save'),
            ),
            SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: _showResetConfirmationDialog,
            //   child: Text('Reset'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red, // Background color
            //   ),
            // ),
            SizedBox(height: 20),
            Text(
              'Hand Cash TK: ${handCash.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),
            const Text(
              'Total Payments Today',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Payment TK: ${totalTodayPayments.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Expense TK: ${todayExpense.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            Text(
              'Total Cash TK: ${totalCash.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}









