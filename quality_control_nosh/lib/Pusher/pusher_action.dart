import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

class PusherAction extends StatefulWidget {
  final String qrData;

  const PusherAction({Key? key, required this.qrData}) : super(key: key);

  @override
  _PusherActionState createState() => _PusherActionState();
}

class _PusherActionState extends State<PusherAction> {
  bool _usbConnected = false;
  UsbPort? _port;
  Timer? _connectionTimer;
  List<String> _sentCommands = [];
  List<String> _receivedCommands = [];
  final _scrollController = ScrollController(); // Scroll controller

  @override
  void initState() {
    super.initState();
    print('Initializing USB communication...');
    _initUsbCommunication();
    _startConnectionTimer();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _closeUsbConnection();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  void _initUsbCommunication() async {
    try {
      final devices = await UsbSerial.listDevices();
      if (devices.isNotEmpty) {
        print('USB device found. Creating port...');
        _port = await devices[0].create();
        await _port!.open();
        await _port!.setDTR(true);
        await _port!.setRTS(true);
        await _port!.setPortParameters(
          38400,
          UsbPort.DATABITS_8,
          UsbPort.STOPBITS_1,
          UsbPort.PARITY_EVEN,
        );

        _port!.inputStream!.listen((Uint8List data) {
          if (data.isNotEmpty) {
            final command = String.fromCharCodes(data);
            print('Received command: $command');
            setState(() {
              _receivedCommands.add(command);
            });
            _scrollToBottom(); // Scroll to the bottom when new data is added
          }
        });

        setState(() {
          _usbConnected = true;
        });
      } else {
        setState(() {
          _usbConnected = false;
        });
      }
    } catch (e) {
      print('Error initializing USB communication: $e');
    }
  }

  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) return; // To prevent calling setState after disposal
      print('Checking USB connection...');
      _initUsbCommunication();
    });
  }

  void _toggleUsbConnection() {
    if (_usbConnected) {
      _closeUsbConnection();
    } else {
      _initUsbCommunication();
    }
  }

  Future<void> _closeUsbConnection() async {
    if (_port != null) {
      await _port!.close();
      _port = null;
    }
    setState(() {
      _usbConnected = false;
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendCommand(String command) async {
    if (_port != null) {
      await _port!.write(Uint8List.fromList(command.codeUnits));
      setState(() {
        _sentCommands.add(command);
      });
      _scrollToBottom(); // Scroll to the bottom when new data is added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.qrData),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add other widgets here

            SizedBox(height: 20), // Add spacing

            // Scrollable container for commands
            Container(
              height: 200, // Set a fixed height or adjust as needed
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                controller: _scrollController, // Assign the scroll controller
                itemCount: _sentCommands.length + _receivedCommands.length,
                itemBuilder: (context, index) {
                  if (index < _sentCommands.length) {
                    return ListTile(
                      title: Text('Sent: ${_sentCommands[index]}'),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                          'Received: ${_receivedCommands[index - _sentCommands.length]}'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleUsbConnection,
        backgroundColor: _usbConnected ? Colors.green : Colors.red,
        child: Icon(Icons.usb),
      ),
    );
  }
}
