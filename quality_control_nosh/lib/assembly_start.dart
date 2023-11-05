import 'package:flutter/material.dart';

class AssemblyDetailPage extends StatelessWidget {
  final String assemblyName;

  AssemblyDetailPage(this.assemblyName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(assemblyName),
      ),
      body: Center(
        child: Text(
          "Details for $assemblyName",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
