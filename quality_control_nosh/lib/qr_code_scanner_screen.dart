import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class QRCodeScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _scanQRCode(context); // Trigger the QR code scan immediately

    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // You can replace this with any loading indicator you prefer
      ),
    );
  }

  Future<void> _scanQRCode(BuildContext context) async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon (if available)
      ScanMode.QR, // Specify the scan mode (QR, BARCODE, etc.)
    );

    if (barcodeScanResult != '-1') {
      _showQRDataDialog(context, barcodeScanResult);
    }
  }

  void _showQRDataDialog(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }
}
