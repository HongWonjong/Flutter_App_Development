// ignore_for_file: library_private_types_in_public_api, duplicate_ignore

import 'package:flutter/material.dart';
import '/cost_input_page.dart';
import '/cost_calculator_page.dart';


void main() {
  runApp(MaterialApp(
    title: "원가 계산기",
    initialRoute: "/cost-input",
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.orange),
    ),
    routes: {
      "/cost-input": (context) => const CostInputPage(),
      "/calculate": (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CostCalculatorPage(costList: args['costList'], quantity: args['quantity'], foodPrice: args['itemPrice']);
      },
    },
  ));
}