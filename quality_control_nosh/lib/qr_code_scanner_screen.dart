import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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

  Future<void> _scanQRCode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon (if available)
      ScanMode.QR, // Specify the scan mode (QR, BARCODE, etc.)
    );

    if (barcodeScanResult != '-1') {
      _showQRDataDialog(barcodeScanResult);
    } else {
      Navigator.of(context).pop(); // Go back if user cancels scan
    }
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
