import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
void onPressed1() {
  // Define what should happen when the button is pressed
  print("Export button pressed");
  // You can add your logic here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          title: Text("Tasks & Expenses"),
          backgroundColor: Colors.orangeAccent,
          centerTitle: true,
          elevation: 0,
          leading: Icon(Icons.menu),
          actions: [TextButton.icon(
              onPressed: onPressed1,
              icon: Icon(Icons.download),
              label: Text("Export"),)],

        )
      ),
    );
  }
}
