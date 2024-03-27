// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print, prefer_const_constructors, unused_element, sort_child_properties_last

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:quality_control_nosh/Pusher/ui.dart';

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
            print('Received command: $command'); // Print received command
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

  void _sendCommand(String command) async {
    if (_port != null) {
      print('Sending command: $command'); // Print the command being sent
      await _port!.write(Uint8List.fromList(command.codeUnits));
      setState(() {
        _sentCommands.add(command);
      });
      _scrollToBottom(); // Scroll to the bottom when new data is added
    }
  }

  _startPlaying() {
    if (_usbConnected) {
      _sendCommandMultipleTimes(
          context, "CMD A", 3, Duration(milliseconds: 500));
    }
  }

  void _sendCommandMultipleTimes(BuildContext pusherContext, String command,
      int times, Duration interval) {
    int sentCount = 0;
    Timer.periodic(interval, (timer) {
      if (sentCount >= times) {
        timer.cancel(); // Stop sending commands if already sent required times
        return;
      }
      if (!_receivedCommands.contains("0")) {
        if (!_receivedCommands.contains("ACMD")) {
          _sendCommand(command);
        } else {
          Timer(Duration(seconds: 2), () {
            if (!_receivedCommands.contains("0")) {
              // "0" not received within 1 second after "ACMD", navigate back to MyPusher
              if (pusherContext != null && Navigator.canPop(pusherContext)) {
                Navigator.pop(pusherContext);
                if (pusherContext != null && Navigator.canPop(pusherContext)) {
                  Navigator.pop(pusherContext);
                  // Show red snackbar indicating to scan QR again
                  ScaffoldMessenger.of(pusherContext).showSnackBar(
                    SnackBar(
                      content: Text('Please scan the QR again'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          });
        }
        sentCount++;
      }
    });
  }

  void _showAssemblySuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Assembly Success"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "All commands sent successfully and assembly is completed."),
                // You can add more information here if needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
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
