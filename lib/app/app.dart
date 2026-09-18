import 'package:flutter/material.dart';

class PaymentPortalApp extends StatelessWidget {
  const PaymentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(child: Center(child: Text('Payment Portal'))),
      ),
    );
  }
}
