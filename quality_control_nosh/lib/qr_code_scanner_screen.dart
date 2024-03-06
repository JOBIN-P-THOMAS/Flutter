// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, use_key_in_widget_constructors, deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeScannerScreen extends StatefulWidget {
  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  @override
  void initState() {
    super.initState();
    _scanQRCode(); // Trigger the QR code scan immediately
  }

  void _scanQRCode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      true,
      ScanMode.QR,
    );

    if (barcodeScanResult != '-1') {
      _saveQRData(barcodeScanResult); // Save the scanned data
      Navigator.pop(context, barcodeScanResult); // Return the scanned result
    } else {
      Navigator.pop(context, ''); // Return an empty string if user cancels scan
    }
  }

  void _saveQRData(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('scannedQRData', data); // Save the data with a key
  }

  void _showQRDataDialog(String qrData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(); // Close the dialog
            return true; // Allow back navigation
          },
          child: AlertDialog(
            title: Text('Scanned QR Data'),
            content: Text(qrData),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // You can replace this with any loading indicator you prefer
      ),
    );
  }
}
