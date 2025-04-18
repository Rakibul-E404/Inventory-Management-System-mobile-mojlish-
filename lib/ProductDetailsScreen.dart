import 'package:flutter/material.dart';
import 'package:mobile_mojlish/productModel.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  final String role;

  const ProductDetailsScreen({required this.product, required this.role, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.image != null)
                Center(
                  child: Image.file(
                    product.image!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16.0),
              _buildDetailRow('Name:', product.name),
              if (role == 'admin') _buildDetailRow('Buying Price:', product.buyingPrice),
              _buildDetailRow('Selling Price:', product.sellingPrice),
              _buildDetailRow('Brand:', product.brand),
              _buildDetailRow('Description:', product.description),
              _buildDetailRow('Barcode:', product.barcode),
              _buildDetailRow('IMEI Number:', product.IMEInumber),
            ],
          ),
        ),
      ),
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
}




