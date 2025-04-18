import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mobile_mojlish/productModel.dart';
import 'package:provider/provider.dart';
import 'AddBrandScreen.dart';
import 'ProductDetailsScreen.dart';
import 'ProductSearchDelegate.dart';
import 'StockProviderPage.dart'; // Updated import for AddBrandScreen

class StockScreen extends StatefulWidget {
  final String role;

  const StockScreen({required this.role, Key? key}) : super(key: key);

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String? _selectedBrandFilter;

  void _addOrEditItem({ProductModel? item, int? index, String? barcode}) async {
    final TextEditingController nameController =
    TextEditingController(text: item?.name ?? '');
    final TextEditingController buyingPriceController =
    TextEditingController(text: item?.buyingPrice ?? '');
    final TextEditingController sellingPriceController =
    TextEditingController(text: item?.sellingPrice ?? '');
    final TextEditingController brandController =
    TextEditingController(text: item?.brand ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: item?.description ?? '');
    final TextEditingController barcodeController =
    TextEditingController(text: barcode ?? item?.barcode ?? '');
    final TextEditingController imeiController =
    TextEditingController(text: item?.IMEInumber ?? '');

    File? imageFile = item?.image;

    final List<String> suggestedBrands =
    Provider.of<StockProvider>(context, listen: false)
        .stockItems
        .map((item) => item.brand)
        .toSet()
        .toList();

    final ProductModel? newItem = await showDialog<ProductModel>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        String? errorMessage; // Define errorMessage here
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item == null ? 'Add Item' : 'Edit Item'),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameController, 'Name', TextInputType.text),
                    _buildTextField(buyingPriceController, 'Buying Price',
                        TextInputType.number),
                    _buildTextField(sellingPriceController, 'Selling Price',
                        TextInputType.number),
                    _buildDropdownField(
                        brandController, 'Brand', suggestedBrands),
                    _buildTextField(descriptionController, 'Description',
                        TextInputType.multiline, 5),
                    _buildTextField(
                        barcodeController, 'Barcode', TextInputType.number),
                    _buildTextField(
                        imeiController, 'IMEI Number', TextInputType.number), // IMEI Number field
                    const SizedBox(height: 10),
                    imageFile == null
                        ? const Text('No image selected.')
                        : Image.file(imageFile!,
                        width: 130, height: 130, fit: BoxFit.cover),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setState(() {
                                imageFile = File(pickedFile.path);
                              });
                            }
                          },
                          icon: const Icon(
                            CupertinoIcons.photo,
                            size: 50,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                            );
                            if (pickedFile != null) {
                              setState(() {
                                imageFile = File(pickedFile.path);
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                        if (imageFile != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                imageFile = null;
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              size: 50,
                              color: Colors.red,
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        buyingPriceController.text.isEmpty ||
                        sellingPriceController.text.isEmpty ||
                        brandController.text.isEmpty ||
                        imeiController.text.isEmpty) {
                      setState(() {
                        errorMessage =
                        'All fields are required without description, barccode & image';
                      });
                      return;
                    }

                    final provider =
                    Provider.of<StockProvider>(context, listen: false);
                    final newItem = ProductModel(
                      name: nameController.text,
                      buyingPrice: buyingPriceController.text,
                      sellingPrice: sellingPriceController.text,
                      image: imageFile,
                      brand: brandController.text,
                      description: descriptionController.text,
                      barcode: barcodeController.text,
                      IMEInumber: imeiController.text,  // Include IMEI number
                      ProductSellPrice: '',
                      payment: '',
                      quantity: '',
                    );

                    if (!provider.isBarcodeUnique(newItem.barcode, index)) {
                      setState(() {
                        errorMessage = 'Barcode must be unique';
                      });
                      return;
                    }

                    Navigator.of(context).pop(newItem);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newItem != null) {
      final provider = Provider.of<StockProvider>(context, listen: false);
      provider.addOrEditItem(newItem, index);
    }
  }





  double _calculateTotalBuyingPrice() {
    final provider = Provider.of<StockProvider>(context, listen: false);
    double total = 0.0;

    for (var item in provider.stockItems) {
      total += double.tryParse(item.buyingPrice) ?? 0.0;
    }

    return total;
  }


  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: label == 'Barcode'
            ? IconButton(
                icon: const Icon(CupertinoIcons.barcode_viewfinder),
                onPressed: _scanBarcode,
              )
            : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField(
    TextEditingController controller,
    String label,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      onChanged: (String? value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      items: Provider.of<StockProvider>(context)
          .suggestedBrands
          .map((String brand) {
        return DropdownMenuItem<String>(
          value: brand,
          child: Text(brand),
        );
      }).toList(),
    );
  }

  void _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // The line color for the scanner
        'Cancel', // The text for the cancel button
        true, // Whether to show the flash icon
        ScanMode.BARCODE, // The scan mode (QR, BARCODE, or DEFAULT)
      );

      if (barcode != '-1') {
        _showBarcodeOptions(
            barcode); // Show options dialog with the scanned barcode
      }
    } catch (e) {
      print('Failed to scan barcode: $e');
    }
  }



  void _showBarcodeOptions(String barcode) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barcode Options'),
          content: const Text("Choose an action for the scanned barcode: "),
          actions: [
            TextButton(
              child: const Text('Add New Item'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _addOrEditItem(
                    barcode: barcode); // Call _addOrEditItem with the barcode
              },
            ),
            TextButton(
              child: const Text('Search Existing Item'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _searchItemByBarcode(
                    barcode); // Call the method to search existing item
              },
            ),
            TextButton(
              child: const Text('Copy Barcode'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: barcode));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barcode copied to clipboard')),
                ); // Call the method to search existing item
              },
            ),
          ],
        );
      },
    );
  }

  void _searchItemByBarcode(String barcode) {
    final provider = Provider.of<StockProvider>(context, listen: false);
    final product = provider.findByBarcode(barcode);
    if (product != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          role: widget.role,
        ),
      ));
    } else {
      _showBarcodeNotFoundDialog(); // Show a dialog if the product is not found
    }
  }

  void _showBarcodeNotFoundDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Not Found'),
          content: const Text('No product found with the scanned barcode.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _filterByBrand(String? brand) {
    setState(() {
      _selectedBrandFilter = brand;
    });
  }



  void _showItemActions(int index) {
    final product =
        Provider.of<StockProvider>(context, listen: false).stockItems[index];
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.info,
                color: Colors.blue,
              ),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      product: product,
                      role: widget.role,
                    ),
                  ),
                );
              },
            ),
            if (widget.role == 'admin') //...[
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(context);
                  _addOrEditItem(item: product, index: index);
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: Colors.grey,
              ),
              title: const Text('Sell Product'),
              onTap: () {
                Navigator.pop(context);
                _showSellProductDialog(index);
              },
            ),
            if (widget.role == 'admin')
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Delete Product'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(index);
                },
              ),
            // ],
          ],
        );
      },
    );
  }

  void _showSellProductDialog(int index) {
    final product =
        Provider.of<StockProvider>(context, listen: false).stockItems[index];
    final TextEditingController sellingPriceController =
        TextEditingController(text: product.sellingPrice.toString(),);
    final TextEditingController memoNumberController = TextEditingController();
    final TextEditingController paymentController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sell Product - ${product.name}'),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      sellingPriceController,
                      'Selling Price',
                      TextInputType.number,
                    ),
                    _buildTextField(
                      paymentController,
                      'Payment',
                      TextInputType.number,
                    ),
                    _buildTextField(memoNumberController, 'Memo Number',
                        TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Sell'),
                  onPressed: () {
                    if (sellingPriceController.text.isEmpty ||
                        paymentController.text.isEmpty ||
                        memoNumberController.text.isEmpty) {
                      setState(() {
                        errorMessage = 'All fields are required';
                      });
                      return;
                    }
                    final provider =
                        Provider.of<StockProvider>(context, listen: false);
                    provider.sellProduct(
                      index,
                      '', // Pass an empty string or modify the method to not require quantity
                      sellingPriceController.text,
                      widget.role,
                      memoNumberController.text, // Pass the memo number
                      '',
                      paymentController.text,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, //Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final provider =
                    Provider.of<StockProvider>(context, listen: false);
                provider.deleteItem(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    final provider = Provider.of<StockProvider>(context, listen: false);
    final brands =
        provider.stockItems.map((item) => item.brand).toSet().toList();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Brand'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Brands'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _filterByBrand(null);
                  },
                  trailing: _selectedBrandFilter == null
                      ? const Icon(Icons.check)
                      : null,
                ),
                ...brands.map((brand) {
                  return ListTile(
                    title: Text(brand),
                    onTap: () {
                      Navigator.of(context).pop();
                      _filterByBrand(brand);
                    },
                    trailing: _selectedBrandFilter == brand
                        ? const Icon(Icons.check)
                        : null,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    List<ProductModel> displayedItems = _selectedBrandFilter == null
        ? provider.stockItems
        : provider.stockItems
        .where((item) => item.brand == _selectedBrandFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(displayedItems),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.barcode_viewfinder),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [



          // Expanded(
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.vertical,
          //     child: SingleChildScrollView(
          //       scrollDirection: Axis.horizontal,
          //       child: Table(
          //         border: TableBorder.all(color: Colors.grey),
          //         columnWidths: const {
          //           0: IntrinsicColumnWidth(), // Auto-size based on content for 'No.'
          //           1: IntrinsicColumnWidth(), // Auto-size based on content for 'Image'
          //           2: IntrinsicColumnWidth(), // Auto-size based on content for 'Name - Brand'
          //           3: IntrinsicColumnWidth(), // Auto-size based on content for 'Barcode'
          //           4: IntrinsicColumnWidth(), // Auto-size based on content for 'Buying Price'
          //         },
          //         children: [
          //           // Table Header
          //           TableRow(
          //             decoration: BoxDecoration(color: Colors.grey[300]),
          //             children: const [
          //               Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Text(
          //                   'No.',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Text(
          //                   'Image',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Text(
          //                   'Name - Brand',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Text(
          //                   'Buying Price',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //               Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Text(
          //                   'Selling Price',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //               ),
          //             ],
          //           ),
          //
          //
          //
          //
          //
          //           // Table Rows
          //           for (int index = 0; index < displayedItems.length; index++)
          //             TableRow(
          //               children: [
          //                 GestureDetector(
          //                   onTap: () => _showItemActions(index),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Text(
          //                       '${index + 1}',
          //                       style: const TextStyle(fontSize: 16),
          //                     ),
          //                   ),
          //                 ),
          //                 GestureDetector(
          //                   onTap: () => _showItemActions(index),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: displayedItems[index].image != null
          //                         ? Image.file(
          //                       displayedItems[index].image!,
          //                       width: 80,
          //                       height: 100,
          //                       fit: BoxFit.cover,
          //                     )
          //                         : const Icon(
          //                       Icons.photo,
          //                       size: 50,
          //                     ),
          //                   ),
          //                 ),
          //                 GestureDetector(
          //                   onTap: () => _showItemActions(index),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Text(
          //                       '${displayedItems[index].name} - ${displayedItems[index].brand}',
          //                     ),
          //                   ),
          //                 ),
          //                 GestureDetector(
          //                   onTap: () => _showItemActions(index),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Text(
          //                       '\$${displayedItems[index].buyingPrice}',
          //                     ),
          //                   ),
          //                 ),
          //                 GestureDetector(
          //                   onTap: () => _showItemActions(index),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Text(
          //                       '\$${displayedItems[index].sellingPrice}',
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),


          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FixedColumnWidth(40), // Auto-size based on content for 'No.'
                      1: FixedColumnWidth(80), // Auto-size based on content for 'Image'
                      2: FixedColumnWidth(150), // Auto-size based on content for 'Name - Brand'
                      3: FixedColumnWidth(100), // Auto-size based on content for 'Barcode'
                      4: FixedColumnWidth(100), // Auto-size based on content for 'Buying Price'
                    },
                    children: [
                      // Table Header
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Image',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Name - Brand',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Buying Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Selling Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FixedColumnWidth(40), // Auto-size based on content for 'No.'
                            1: FixedColumnWidth(80), // Auto-size based on content for 'Image'
                            2: FixedColumnWidth(150), // Auto-size based on content for 'Name - Brand'
                            3: FixedColumnWidth(100), // Auto-size based on content for 'Barcode'
                            4: FixedColumnWidth(100), // Auto-size based on content for 'Buying Price'
                          },
                          children: [
                            // Table Rows
                            for (int index = 0; index < displayedItems.length; index++)
                              TableRow(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showItemActions(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showItemActions(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: displayedItems[index].image != null
                                          ? Image.file(
                                        displayedItems[index].image!,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      )
                                          : const Icon(
                                        Icons.photo,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showItemActions(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${displayedItems[index].name} - ${displayedItems[index].brand}',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showItemActions(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '\$${displayedItems[index].buyingPrice}',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showItemActions(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '\$${displayedItems[index].sellingPrice}',
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
          ),







          /// it was main design
          // Expanded(
          //   child: Column(
          //     children: [
          //       // First Table Row
          //       SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         child: Table(
          //           border: TableBorder.all(color: Colors.grey),
          //           columnWidths: const {
          //             0: IntrinsicColumnWidth(),
          //             1: IntrinsicColumnWidth(),
          //             2: IntrinsicColumnWidth(),
          //             3: IntrinsicColumnWidth(),
          //             4: IntrinsicColumnWidth(),
          //           },
          //           children: [
          //             // Table Header
          //             TableRow(
          //               decoration: BoxDecoration(color: Colors.grey[300]),
          //               children: const [
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'No.',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'Image',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'Name - Brand',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'Buying Price',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'Selling Price',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //
          //
          //
          //
          //       // Other Data Table
          //       SingleChildScrollView(
          //         scrollDirection: Axis.vertical,
          //         child: SingleChildScrollView(
          //           scrollDirection: Axis.horizontal,
          //           child: Table(
          //             border: TableBorder.all(color: Colors.grey),
          //             columnWidths: const {
          //               0: IntrinsicColumnWidth(),
          //               1: IntrinsicColumnWidth(),
          //               2: IntrinsicColumnWidth(),
          //               3: IntrinsicColumnWidth(),
          //               4: IntrinsicColumnWidth(),
          //             },
          //             children: [
          //               // Table Header
          //               for (int index = 0; index < displayedItems.length; index++)
          //                 TableRow(
          //                   children: [
          //                     GestureDetector(
          //                       onTap: () => _showItemActions(index),
          //                       child: Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: Text(
          //                           '${index + 1}',
          //                           style: const TextStyle(fontSize: 16),
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: () => _showItemActions(index),
          //                       child: Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: displayedItems[index].image != null
          //                             ? Image.file(
          //                           displayedItems[index].image!,
          //                           width: 80,
          //                           height: 100,
          //                           fit: BoxFit.cover,
          //                         )
          //                             : const Icon(
          //                           Icons.photo,
          //                           size: 50,
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: () => _showItemActions(index),
          //                       child: Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: Text(
          //                           '${displayedItems[index].name} - ${displayedItems[index].brand}',
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: () => _showItemActions(index),
          //                       child: Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: Text(
          //                           '\$${displayedItems[index].buyingPrice}',
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: () => _showItemActions(index),
          //                       child: Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: Text(
          //                           '\$${displayedItems[index].sellingPrice}',
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),





          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Floating Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: SpeedDial(
                    icon: Icons.add,
                    activeIcon: Icons.close,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    children: [
                      SpeedDialChild(
                        child: const Icon(CupertinoIcons.cube_box_fill),
                        label: 'Add Product',
                        onTap: () => _addOrEditItem(),
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.branding_watermark),
                        label: 'Add Brand',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddBrandScreen(userRole: widget.role),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Add some spacing between the FAB and the total
                // Total Buying Price
                Text(
                  'Total Buying Price: \$${_calculateTotalBuyingPrice().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



///
///
///
///
/// ---------using shared preference
///
///




