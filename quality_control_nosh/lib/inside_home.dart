// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:quality_control_nosh/assembly_start.dart';

class TestingAssembly extends StatelessWidget {
  final String assemblyName;

  const TestingAssembly({Key? key, required this.assemblyName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        SafeArea(
          child: Container(
            height: 80,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    assemblyName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 6),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 7,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssemblyDetailPage(assemblyName),
                ),
              );
            },
            child: ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.orange)),
              child: Text(
                "CHECK",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
