// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_super_parameters

import 'package:flutter/material.dart';
import 'package:quality_control_nosh/qr_code_scanner_screen.dart';
import 'package:quality_control_nosh/Pusher/pusher_action.dart';

class MyPusher extends StatelessWidget {
  const MyPusher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 5,
        title: const Text('PUSHER'),
        centerTitle: true,
      ),
      backgroundColor:
          Colors.grey[200], // Set scaffold background color to grey 500
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color:
                    Colors.white, // Container background color (can be changed)
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'lib/assets/Screenshot pusher.png', // Image asset path
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 80),
            GestureDetector(
              onTap: () async {
                // Navigate to QR code scanner screen
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QRCodeScannerScreen()),
                );

                if (result != null && result.isNotEmpty) {
                  // Navigate to PusherAction page with QR data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PusherAction(qrData: result),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.qr_code, color: Colors.white, size: 32),
                    SizedBox(width: 10),
                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Welcome to PUSHER testing!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap the button above to scan a QR code to testing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
