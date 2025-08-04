import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String contestId;

  PaymentScreen({required this.contestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(child: Text('Payment Screen for Contest ID: $contestId')),
    );
  }
}