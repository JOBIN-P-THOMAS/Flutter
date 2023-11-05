// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quality_control_nosh/inside_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TestingAssembly(
                  assemblyName: "PLATFORM",
                ),
                TestingAssembly(
                  assemblyName: "PUSHER",
                ),
                TestingAssembly(
                  assemblyName: "STIRRER",
                ),
                TestingAssembly(
                  assemblyName: "SPICE",
                ),
                TestingAssembly(
                  assemblyName: "WATER",
                ),
                TestingAssembly(
                  assemblyName: "OIL",
                ),
              ],
            ),
          )),

      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Center(child: Text("loged in as ${user.email!}")),
      //     MaterialButton(
      //       onPressed: () {
      //         FirebaseAuth.instance.signOut();
      //       },
      //       color: Colors.orange,
      //       child: Text('sign out'),
      // )
      // ],
      // ),
    );
  }
}
