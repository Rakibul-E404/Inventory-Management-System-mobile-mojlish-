
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'StockProviderPage.dart';

class AddBrandScreen extends StatelessWidget {
  final String userRole; // Add a userRole parameter

  AddBrandScreen({required this.userRole}); // Add constructor

  @override
  Widget build(BuildContext context) {
    final TextEditingController brandController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Brand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'Brand Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String brandName = brandController.text.trim();
                if (brandName.isNotEmpty) {
                  Provider.of<StockProvider>(context, listen: false).addBrand(brandName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Brand'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Brand List:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Consumer<StockProvider>(
                builder: (context, stockProvider, child) {
                  return ListView.builder(
                    itemCount: stockProvider.suggestedBrands.length,
                    itemBuilder: (context, index) {
                      final brand = stockProvider.suggestedBrands[index];
                      return ListTile(
                        title: Text(brand),
                        trailing: userRole == 'admin' // Check if user is admin
                            ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            stockProvider.removeBrand(brand);
                          },
                        )
                            : null, // Hide the delete button if not admin
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



