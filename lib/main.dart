
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DashBoard.dart';
import 'Login.dart';
import 'StockProviderPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockProvider(),
      child: MaterialApp(
        title: 'Your App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        // home: const LoginScreen(),
        home: const Dashboard(role: 'admin', stockItems: [],),
      ),
    );
  }
}