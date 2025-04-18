import 'package:flutter/material.dart';
import 'package:mobile_mojlish/productModel.dart';

class ProductSearchDelegate extends SearchDelegate<ProductModel?> {
  final List<ProductModel> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<ProductModel> results = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.brand.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query);  // Barcode match
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: product.image != null
              ? Image.file(product.image!, width: 80, height: 100, fit: BoxFit.cover)
              : const Icon(Icons.photo, size: 50),
          title: _highlightText(product.name, query),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightText("Brand: ${product.brand}", query),
              _highlightText("Barcode: ${product.barcode}", query),
              Text("${product.buyingPrice} - ${product.sellingPrice}"),
            ],
          ),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ProductModel> suggestions = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.brand.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query);  // Barcode match
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          leading: product.image != null
              ? Image.file(product.image!, width: 80, height: 100, fit: BoxFit.cover)
              : const Icon(Icons.photo, size: 50),
          title: _highlightText(product.name, query),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightText("Brand: ${product.brand}", query),
              _highlightText("Barcode: ${product.barcode}", query),
              Text("${product.buyingPrice} - ${product.sellingPrice}"),
            ],
          ),
          onTap: () {
            query = product.name;
            showResults(context);
          },
        );
      },
    );
  }

  // Helper method to highlight matched text
  RichText _highlightText(String text, String query) {
    if (query.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = lowerText.indexOf(lowerQuery, start);

      if (indexOfHighlight < 0) {
        // No more matches, add the rest of the text
        spans.add(TextSpan(
          text: text.substring(start),
          style: const TextStyle(color: Colors.black),
        ));
        break;
      }

      // Add the text before the highlight
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
          style: const TextStyle(color: Colors.black),
        ));
      }

      // Add the highlighted text
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + query.length),
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ));

      // Move past the highlighted text
      start = indexOfHighlight + query.length;
    } while (start < text.length);

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
