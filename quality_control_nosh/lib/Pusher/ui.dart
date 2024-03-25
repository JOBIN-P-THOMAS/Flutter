// import 'dart:async';
// import 'dart:typed_data';
// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
// import 'package:usb_serial/usb_serial.dart';
import 'package:quality_control_nosh/qr_code_scanner_screen.dart'; // Import your QR code scanner screen
import 'package:quality_control_nosh/Pusher/pusher_action.dart';

class MyPusher extends StatefulWidget {
  const MyPusher({Key? key}) : super(key: key);

  @override
  State<MyPusher> createState() => _MyPusherState();
}

class _MyPusherState extends State<MyPusher> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.orange,
          elevation: 5, // Add elevation (shadow)
          title: Row(
            children: [
              const Text('PUSHER'),
              const Spacer(), // Add spacer to push USB status to the right

              const SizedBox(width: 10), // Add space between text and icon
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20), // Add gap below AppBar
          GestureDetector(
            onTap: () async {
              // Navigate to QR code scanner screen when Scan QR button tapped
              String result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
              );

              // Check if the result is not null or empty
              if (result != null && result.isNotEmpty) {
                // Navigate to the PusherAction page after scanning the QR code
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PusherAction(
                          qrData: result)), // Pass QR data to PusherAction
                );
              }
            },
            child: Container(
              height: 80, // Set container height
              margin: const EdgeInsets.symmetric(
                  horizontal: 20), // Add horizontal margin
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius:
                    BorderRadius.circular(20), // Apply rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Scan QR',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Your existing content widgets go here
                    Text(
                      'PUSHER',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
