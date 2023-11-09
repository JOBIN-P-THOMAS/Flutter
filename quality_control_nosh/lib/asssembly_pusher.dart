// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';

class AssemblyDetailPagePusher extends StatefulWidget {
  final String assemblyName;

  AssemblyDetailPagePusher(this.assemblyName);

  @override
  _AssemblyDetailPagePusherState createState() =>
      _AssemblyDetailPagePusherState();
}

class _AssemblyDetailPagePusherState extends State<AssemblyDetailPagePusher> {
  UsbPort? port;
  String response = '';
  TextEditingController commandController = TextEditingController();
  int selectedBaudRate = 38400;
  bool isPortOpen = false;
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.assemblyName),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildCheckContainer('Top Limit', checkStatus[0]),
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
