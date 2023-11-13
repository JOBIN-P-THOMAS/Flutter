// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:quality_control_nosh/qr_code_scanner_screen.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';

class AssemblyDetailPageStirrer extends StatefulWidget {
  final String assemblyName;

  AssemblyDetailPageStirrer(this.assemblyName);

  @override
  _AssemblyDetailPageStirrerState createState() =>
      _AssemblyDetailPageStirrerState();
}

class _AssemblyDetailPageStirrerState extends State<AssemblyDetailPageStirrer> {
  UsbPort? port;
  String response = '';
  TextEditingController commandController = TextEditingController();
  int selectedBaudRate = 38400;
  bool isPortOpen = false;
  String scannedQRCode = '';

  List<bool> checkStatus = List.filled(6, false); // Initialize with false

  Future<void> _initUsbCommunication() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      port = await devices[0].create();
      await port!.open();
      await port!.setDTR(true);
      await port!.setRTS(true);
      await port!.setPortParameters(
        selectedBaudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_EVEN,
      );
      port!.inputStream!.listen((Uint8List data) {
        String partialResponse = String.fromCharCodes(data);
        List<String> lines = partialResponse.split('\n');
        for (String line in lines) {
          setState(() {
            response += line + '\n';
          });
        }
      });
      setState(() {
        isPortOpen = true;
      });
      _showPopupMessage('Connected');
    } else {
      _showPopupMessage('No connected devices found.');
    }
  }

  void _togglePortConnection() {
    if (isPortOpen) {
      port!.close();
      setState(() {
        isPortOpen = false;
      });
      _showPopupMessage('Disconnected');
    } else {
      _initUsbCommunication();
    }
  }

  void _showPopupMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startButtonAction() async {
    if (!isPortOpen) {
      _showPopupMessage('USB port is not open.');
      return;
    }

    if (scannedQRCode.isEmpty) {
      _showPopupMessage('Scan a QR code first.');
      return;
    }

    final commands = [
      {'command': 'CMD I 001', 'expectedResponse': '0'},
      {'command': 'CMD J 001', 'expectedResponse': '0'},
      {'command': 'CMD R 001', 'expectedResponse': '0'},
      {'command': 'CMD e 001', 'expectedResponse': '0'},
    ];

    for (var i = 0; i < commands.length; i++) {
      final command = commands[i]['command'];
      final expectedResponse = commands[i]['expectedResponse'];

      if (command != null) {
        await port!.write(Uint8List.fromList(command.codeUnits));

        final responseTimeout = Duration(seconds: 10);
        final response =
            await _waitForResponse(expectedResponse!, responseTimeout);

        if (response != expectedResponse && response != '\$STATUS: 0') {
          _updateCheckStatus(i, false);
          _showPopupMessage('Assembly failed. Response: $response');
          break;
        } else {
          _updateCheckStatus(i, true);
        }
      }
    }

    if (checkStatus.every((check) => check)) {
      _showPopupMessage('All checks completed.');
    }
  }

  Future<String> _waitForResponse(
      String expectedResponse, Duration timeout) async {
    final completer = Completer<String>();
    final responseListener = port!.inputStream!.listen((Uint8List data) {
      final response = String.fromCharCodes(data).trim();
      if (response.isNotEmpty) {
        completer.complete(response);
      }
    });

    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete('');
      }
    });

    final response = await completer.future;
    responseListener.cancel();
    return response;
  }

  void _updateCheckStatus(int index, bool isSuccess) {
    setState(() {
      checkStatus[index] = isSuccess;
    });
  }

  void _stopButtonAction() {
    // Add any necessary actions for the stop button here
  }

  @override
  Widget build(BuildContext context) {
    void _scanQRCode() async {
      // Open the QR code scanner screen
      String result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
      );

      // Update the scanned QR code
      if (result.isNotEmpty) {
        setState(() {
          scannedQRCode = result;
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          '${widget.assemblyName} - ${isPortOpen ? 'Connected' : 'Disconnected'}',
          style: TextStyle(color: isPortOpen ? Colors.green : Colors.white),
        ),
        backgroundColor: Colors.orange[700],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onTap: _scanQRCode,
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.orange[700],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan Stirrer QR to start',
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                        Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildCheckContainer('Top Liiimit', checkStatus[0]),
              _buildCheckContainer('Bottom Limit', checkStatus[1]),
              _buildCheckContainer('Motor Encoder Check', checkStatus[2]),
              _buildCheckContainer('BLDC + Limit Check', checkStatus[3]),
              _buildCheckContainer('Assembly Smooth Check', checkStatus[4]),
              // _buildCheckContainer('BLDC Smooth Check', checkStatus[5]),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: _startButtonAction,
              backgroundColor: Colors.green,
              child: Icon(Icons.play_arrow),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: _stopButtonAction,
              backgroundColor: Colors.red,
              child: Icon(Icons.stop),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: _togglePortConnection,
              backgroundColor: isPortOpen ? Colors.green : Colors.red,
              child: Icon(isPortOpen ? Icons.usb : Icons.usb_off),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckContainer(String checkName, bool isSuccess) {
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[400],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              checkName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(right: 5),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            child: Icon(
              isSuccess ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
