// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'DashBoard.dart';
// import 'StockProviderPage.dart';
//
// class SoldItemScreen extends StatefulWidget {
//   const SoldItemScreen({super.key});
//
//   @override
//   _SoldItemScreenState createState() => _SoldItemScreenState();
// }
//
// class _SoldItemScreenState extends State<SoldItemScreen> {
//   DateTime? _startDate;
//   DateTime? _endDate;
//   String? _filterByRole;
//
//   @override
//   void initState() {
//     super.initState();
//     _filterSoldItems();
//   }
//
//   void _filterSoldItems() {
//     final provider = Provider.of<StockProvider>(context, listen: false);
//     provider.filterSoldItems(_startDate, _endDate, _filterByRole);
//   }
//
//   void _filterLast7Days() {
//     setState(() {
//       _startDate = DateTime.now().subtract(Duration(days: 7));
//       _endDate = DateTime.now();
//       _filterByRole = null;
//       _filterSoldItems();
//     });
//   }
//
//   void _filterByRoleFunction(String role) {
//     setState(() {
//       _filterByRole = role;
//       _filterSoldItems();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<StockProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sold Items'),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const Dashboard(role: 'admin', stockItems: []),
//               ),
//             );
//           },
//           icon: const Icon(Icons.arrow_back_outlined),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               switch (value) {
//                 case 'last_7_days':
//                   _filterLast7Days();
//                   break;
//                 case 'by_admin':
//                   _filterByRoleFunction('admin');
//                   break;
//                 case 'by_moderator':
//                   _filterByRoleFunction('moderator');
//                   break;
//                 case 'clear':
//                   setState(() {
//                     _startDate = null;
//                     _endDate = null;
//                     _filterByRole = null;
//                     _filterSoldItems();
//                   });
//                   provider.clearSoldItemFilters();
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem<String>(
//                 value: 'last_7_days',
//                 child: Text('Last 7 Days'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'by_admin',
//                 child: Text('By Admin'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'by_moderator',
//                 child: Text('By Moderator'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'clear',
//                 child: Text('Clear Filters'),
//               ),
//             ],
//             child: const Icon(Icons.more_vert, color: Colors.purple),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       final DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2101),
//                       );
//                       if (pickedDate != null && pickedDate != _startDate) {
//                         setState(() {
//                           _startDate = pickedDate;
//                           _filterSoldItems();
//                         });
//                       }
//                     },
//                     child: Text(_startDate == null
//                         ? 'Start Date'
//                         : DateFormat('yyyy-MM-dd').format(_startDate!)),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       final DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2101),
//                       );
//                       if (pickedDate != null && pickedDate != _endDate) {
//                         setState(() {
//                           _endDate = pickedDate;
//                           _filterSoldItems();
//                         });
//                       }
//                     },
//                     child: Text(_endDate == null
//                         ? 'End Date'
//                         : DateFormat('yyyy-MM-dd').format(_endDate!)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('Index')),
//                   DataColumn(label: Text('Sold By')),
//                   DataColumn(label: Text('Item')),
//                   DataColumn(label: Text('Price Set')),
//                   DataColumn(label: Text('Sold Price')),
//                   DataColumn(label: Text('Payment')),
//                   DataColumn(label: Text('Memo')),
//                   DataColumn(label: Text('IMEI Number')),
//                   DataColumn(label: Text('Date')),
//                 ],
//                 rows: List<DataRow>.generate(
//                   provider.filteredSoldItems.length,
//                       (index) {
//                     final item = provider.filteredSoldItems[index];
//
//                     print('Payment: ${item.payment}, IMEI: ${item.IMEInumber}');
//                     DateTime dateTime = DateFormat("yyyy-MM-dd – hh:mm").parse(item.dateTime);
//                     String formattedDate = DateFormat("yyyy-MM-dd – hh:mm").format(dateTime);
//
//                     return DataRow(
//                       cells: [
//                         DataCell(Text('${index + 1}')),
//                         DataCell(Text(item.soldBy)),
//                         DataCell(Text(item.name)),
//                         DataCell(Text(item.sellingPrice)),
//                         DataCell(Text(item.ProductSellPrice)),
//                         DataCell(Text(item.payment)),
//                         DataCell(Text(item.memoNumber)),
//                         DataCell(Text(item.IMEInumber)),
//                         DataCell(Text(formattedDate)),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


///
///
///
///
///-----------showing everything into details button
///
///



import 'dart:io'; // Import to use File class
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_mojlish/productModel.dart';
import 'package:provider/provider.dart';
import 'DashBoard.dart';
import 'StockProviderPage.dart';

class SoldItemScreen extends StatefulWidget {
  const SoldItemScreen({super.key});

  @override
  _SoldItemScreenState createState() => _SoldItemScreenState();
}

class _SoldItemScreenState extends State<SoldItemScreen> {
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

  void _filterByRoleFunction(String role) {
    setState(() {
      _filterByRole = role;
      _filterSoldItems();
    });
  }

  void _showProductDetails(ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.image != null && product.image!.existsSync())
                  Center(
                    child: Image.file(
                      product.image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Center(
                    child: Text("No Image Available"),
                  ),
                _buildDetailRow('Sold Price:', product.ProductSellPrice.toString()),
                const SizedBox(height: 20.0),
                _buildDetailRow('Memo:', product.memoNumber),
                _buildDetailRow('Name:', product.name),
                if (_filterByRole == 'admin') _buildDetailRow('Buying Price:', product.buyingPrice.toString()),
                _buildDetailRow('Brand:', product.brand),
                _buildDetailRow('Description:', product.description),
                _buildDetailRow('Barcode:', product.barcode),
                _buildDetailRow('Sold By:', product.soldBy),
                _buildDetailRow('Buying Price:', product.buyingPrice.toString()),
                _buildDetailRow('Selling Price:', product.sellingPrice.toString()),
                _buildDetailRow('IMEI Number:', product.IMEInumber),
                _buildDetailRow('Date:', product.dateTime),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sold Items'),
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
            child: const Icon(Icons.more_vert, color: Colors.purple),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _startDate) {
                        setState(() {
                          _startDate = pickedDate;
                          _filterSoldItems();
                        });
                      }
                    },
                    child: Text(_startDate == null
                        ? 'Start Date'
                        : DateFormat('yyyy-MM-dd').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _endDate) {
                        setState(() {
                          _endDate = pickedDate;
                          _filterSoldItems();
                        });
                      }
                    },
                    child: Text(_endDate == null
                        ? 'End Date'
                        : DateFormat('yyyy-MM-dd').format(_endDate!)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Sl No.')),
                  DataColumn(label: Text('Sold By')),
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Sold Price')),
                  DataColumn(label: Text('Memo')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actiion')),
                ],
                rows: List<DataRow>.generate(
                  provider.filteredSoldItems.length,
                      (index) {
                    final item = provider.filteredSoldItems[index];
                    DateTime dateTime = DateFormat("yyyy-MM-dd – hh:mm").parse(item.dateTime);
                    String formattedDate = DateFormat("yyyy-MM-dd – hh:mm").format(dateTime);

                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(item.soldBy)),
                        DataCell(Text(item.name)),
                        DataCell(Text(item.ProductSellPrice.toString())),
                        DataCell(Text(item.memoNumber)),
                        DataCell(Text(formattedDate)),
                        DataCell(IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showProductDetails(item);
                          },
                        )),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

