// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print, prefer_const_constructors, unused_element, sort_child_properties_last, prefer_const_declarations

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
// import 'package:quality_control_nosh/Pusher/ui.dart';

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
  bool _isPlaying = false; // Track play/stop state

  bool _isInitialized =
      false; // Flag to track if initialization process has occurred

  @override
  void initState() {
    super.initState();
    print('Initializing USB communication...');
    if (!_isInitialized) {
      _initUsbCommunication();
      _isInitialized =
          true; // Set flag to indicate initialization process has occurred
    }
    _startConnectionTimer();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel(); // Stop the timer
    _closeUsbConnection();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  bool _isCreatingPort = false; // Flag to track if port creation is ongoing

  void _initUsbCommunication() async {
    try {
      if (_isCreatingPort) {
        // If port creation is already ongoing, return to prevent duplication
        return;
      }
      _isCreatingPort =
          true; // Set flag to indicate port creation process started

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
            // print('Received command: $command'); // Print received command
            setState(() {
              _receivedCommands.add(command);
            });
            _scrollToBottom(); // Scroll to the bottom when new data is added
          }
        }, onError: (error) {
          print('Error receiving data: $error');
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
    } finally {
      _isCreatingPort =
          false; // Reset the flag after port creation process completes
    }
  }

  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) return; // To prevent calling setState after disposal
      if (!_usbConnected) {
        print('Checking USB connection...');
        _initUsbCommunication();
      }
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
    // Scroll to the bottom always
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  _startPlaying() {
    if (_usbConnected && _port != null) {
      final command = 'CMD A 001\r\n';
      _port!.write(Uint8List.fromList(command.codeUnits));
      setState(() {
        _sentCommands.add(command);
      });
      _scrollToBottom();
      _waitForResponse();
    }
  }

  void _waitForResponse() {
    // Set a flag to indicate waiting for response
    bool waitingForResponse = true;

    // Start a timer to stop waiting after 6 seconds
    Timer(Duration(seconds: 6), () {
      // Stop waiting after 6 seconds
      waitingForResponse = false;
    });

    _port!.inputStream!.listen((Uint8List data) async {
      if (!waitingForResponse) return; // Ignore responses after 6 seconds

      if (data.isNotEmpty) {
        final response = String.fromCharCodes(data);
        print('Received response: $response');

        if (response.trim() == '0') {
          // Received expected response, stop waiting
          waitingForResponse = false;

          // Process the response or perform any necessary actions
          print('Received expected response: $response');

          // _showCheckContainer(); // Display the "Check 1" container

          final command = 'CMD A 002\r\n';
          _port!.write(Uint8List.fromList(command.codeUnits));
          setState(() {
            _sentCommands.add(command);
          });
          _scrollToBottom();
          _waitForResponseAfterCmdA002();
        }
      }
    });
  }

  void _waitForResponseAfterCmdA002() {
    // Set a flag to indicate waiting for response
    bool waitingForResponse = true;

    // Start a timer to stop waiting after 6 seconds
    Timer(Duration(seconds: 6), () {
      // Stop waiting after 6 seconds
      waitingForResponse = false;
    });

    _port!.inputStream!.listen((Uint8List data) async {
      if (!waitingForResponse) return; // Ignore responses after 6 seconds

      if (data.isNotEmpty) {
        final response = String.fromCharCodes(data);
        print('Received response: $response');

        if (response.trim() == '0') {
          // Received expected response, stop waiting
          waitingForResponse = false;

          // Process the response or perform any necessary actions
          print('Received expected response: $response');

          // _showCheckContainer(); // Display the "Check 1" container

          final command = 'CMD A 003\r\n';
          _port!.write(Uint8List.fromList(command.codeUnits));
          setState(() {
            _sentCommands.add(command);
          });
          _scrollToBottom();
          _waitForResponseAfterCmdA003();
        }
      }
    });
  }

  void _waitForResponseAfterCmdA003() {
// Set a flag to indicate waiting for response
    bool waitingForResponse = true;

    // Start a timer to stop waiting after 6 seconds
    Timer(Duration(seconds: 6), () {
      // Stop waiting after 6 seconds
      waitingForResponse = false;
    });

    _port!.inputStream!.listen((Uint8List data) async {
      if (!waitingForResponse) return; // Ignore responses after 6 seconds

      if (data.isNotEmpty) {
        final response = String.fromCharCodes(data);
        print('Received response: $response');

        if (response.trim() == '0') {
          // Received expected response, stop waiting
          waitingForResponse = false;

          // Process the response or perform any necessary actions
          print('Received expected response: $response');

          // _showCheckContainer(); // Display the "Check 1" container

          // final command = 'CMD A 003\r\n';
          // _port!.write(Uint8List.fromList(command.codeUnits));
          // setState(() {
          //   _sentCommands.add(command);
          // });
          // _scrollToBottom();
          // _waitForResponseAfterCmdA003();
        }
      }
    });
  }

  void _showCheckContainer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check 1'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _stopPlaying() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.qrData),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20), // Add spacing
          // Scrollable container for commands
          Container(
            height: 400, // Set a fixed height or adjust as needed
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sentCommands.length + _receivedCommands.length,
              itemBuilder: (context, index) {
                if (index < _sentCommands.length) {
                  final sentCommand = _sentCommands[index];
                  if (sentCommand.isNotEmpty) {
                    return ListTile(
                      title: Text('Sent: $sentCommand'),
                    );
                  } else {
                    return SizedBox.shrink(); // Skip empty sent commands
                  }
                } else {
                  final receivedIndex = index - _sentCommands.length;
                  if (receivedIndex >= 0 &&
                      receivedIndex < _receivedCommands.length) {
                    final receivedCommand = _receivedCommands[receivedIndex];
                    if (receivedCommand.isNotEmpty) {
                      return ListTile(
                        title: Text('Received: $receivedCommand'),
                      );
                    } else {
                      return SizedBox.shrink(); // Skip empty received commands
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleUsbConnection,
            backgroundColor: _usbConnected ? Colors.green : Colors.red,
            child: Icon(Icons.usb),
            heroTag: null,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Toggle between play and stop
              setState(() {
                _isPlaying = !_isPlaying;
              });
              if (_isPlaying) {
                _startPlaying();
              } else {
                _stopPlaying();
              }
            },
            backgroundColor: _isPlaying
                ? Colors.red
                : Colors.green, // Change button color based on state
            child: Icon(_isPlaying
                ? Icons.stop
                : Icons.play_arrow), // Change icon based on state
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
