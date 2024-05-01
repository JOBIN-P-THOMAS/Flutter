// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print, prefer_const_constructors, unused_element, sort_child_properties_last, prefer_const_declarations, sized_box_for_whitespace, use_build_context_synchronously, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, unnecessary_import, unused_import

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:quality_control_nosh/Pusher/ui.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // For accessing platform channel
import 'package:path_provider/path_provider.dart';
// import 'package:quality_control_nosh/Pusher/ui.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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
    requestPermission();
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
    _port?.close(); // Close USB port if it's open
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

        _port!.inputStream!.listen(
          (Uint8List data) {
            if (data.isNotEmpty) {
              final command = String.fromCharCodes(data).trim();
              print('Received command: $command');

              setState(() {
                _receivedCommands.add(command);
              });

              // Scroll to the bottom when new data is added
              _scrollToBottom();
            }
          },
          onError: (error) {
            print('Error receiving data: $error');
          },
        );

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
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 10),
      curve: Curves.easeOut,
    );
  }

  Future<void> requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        // Permission denied, handle it accordingly
        print('Permission denied');
      }
    }
  }

  _startPlaying() {
    if (_usbConnected && _port != null) {
      setState(() {
        _isPlaying = true; // Set playing state to true
      });

      // Show a loading indicator while waiting for response
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing dialog with outside tap
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Testing Assembly'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('please wait.....'),
              ],
            ),
          );
        },
      );

      final command = 'CMD A 001\r\n';
      _port!.write(Uint8List.fromList(command.codeUnits));
      setState(() {
        _sentCommands.add(command);
      });

      _waitForResponse(); // Start waiting for response
    }
  }

  void _waitForResponse() {
    // Set a flag to indicate waiting for response
    bool waitingForResponse = true;

    // Start a timer to stop waiting after 26 seconds
    Timer timeoutTimer = Timer(Duration(seconds: 26), () {
      if (waitingForResponse && mounted) {
        // If no response has been received and the widget is still mounted
        print('Response timeout, stopping playback');
        _stopPlaying(); // Stop playing if timeout occurs
      }
    });

    _port!.inputStream!.listen((Uint8List data) async {
      if (!waitingForResponse || !mounted)
        return; // Check mounted before setState

      if (data.isNotEmpty) {
        final response = String.fromCharCodes(data).trim();
        print('Received response: $response');

        if (response.trim() == '-101') {
          // Received response code '-101', stop waiting and trigger _stopPlaying()
          waitingForResponse = false;
          timeoutTimer.cancel(); // Cancel the timeout timer
          _stopPlaying(); // Trigger stop playing action
        } else if (response.trim() == '0') {
          // Received response code '0', stop waiting and trigger _success()
          waitingForResponse = false;
          timeoutTimer.cancel(); // Cancel the timeout timer
          _success(); // Trigger success action
        }
      }
    });
  }

  void _stopPlaying() async {
    try {
      final directory = Directory('/storage/emulated/0/Download');

      // Check if the Download directory exists, create it if not
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final qrCodeData = widget.qrData;
      final now = DateTime.now();
      final timestamp =
          '${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}';
      // final timestamp = DateTime.now().minute;
      String fileName = '$qrCodeData-$timestamp.txt';
      String fileNameAWS = '$qrCodeData-$timestamp';
      // String fileName = '$qrCodeData.txt';
      String filePath = '${directory.path}/$fileName';

      // Check if the file already exists in the Download directory
      int count = 1;
      while (await File(filePath).exists()) {
        // File already exists, generate a new file name with a count
        fileName = '$qrCodeData-$count.txt';
        filePath = '${directory.path}/$fileName';
        count++;
      }

      final file = File(filePath);

      String content = 'Sent Commands:\n';
      for (final command in _sentCommands) {
        content += '$command\n';
      }
      content += '\nReceived Commands:\n';
      for (final command in _receivedCommands) {
        content += '$command\n';
      }

      await file.writeAsString(content);

      print('Commands saved to $filePath');

      final apiUrl =
          'https://fls8oe8xp7.execute-api.ap-south-1.amazonaws.com/dev/nosh-test-S3?file_name=$fileNameAWS';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: content,
        headers: {
          'Content-Type': 'text/plain'
        }, // Specify content type as text/plain
      );

      if (response.statusCode == 200) {
        print('Commands sent to S3 successfully');
      } else {
        print(
            'Failed to send commands to S3. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving and sending commands: $e');
    }

    // Show a custom dialog indicating assembly failure
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear,
                  size: 60,
                  color: Colors.red,
                ),
                SizedBox(height: 20),
                Text(
                  'Assembly Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'QR Data: ${widget.qrData}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Sent Commands:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sentCommands.length,
                    itemBuilder: (context, index) {
                      final sentCommand = _sentCommands[index];
                      return ListTile(
                        title: Text(
                          'Sent: $sentCommand',
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Received Commands:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _receivedCommands.length,
                    itemBuilder: (context, index) {
                      final receivedCommand = _receivedCommands[index];
                      return ListTile(
                        title: Text(
                          'Received: $receivedCommand',
                          style: TextStyle(color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyPusher()),
                      (route) => false, // Remove all routes until the new route
                    );
                    // Navigate to MyPusher page
                  },
                  child: Text('OK', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _success() async {
    try {
      final directory = Directory('/storage/emulated/0/Download');

      // Check if the Download directory exists, create it if not
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final qrCodeData = widget.qrData;
      final now = DateTime.now();
      final timestamp =
          '${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}';
      // final timestamp = DateTime.now().minute;
      String fileName = '$qrCodeData-$timestamp.txt';
      String fileNameAWS = '$qrCodeData-$timestamp';
      // String fileName = '$qrCodeData.txt';
      String filePath = '${directory.path}/$fileName';

      // Check if the file already exists in the Download directory
      int count = 1;
      while (await File(filePath).exists()) {
        // File already exists, generate a new file name with a count
        fileName = '$qrCodeData-$count.txt';
        filePath = '${directory.path}/$fileName';
        count++;
      }

      final file = File(filePath);

      String content = 'Sent Commands:\n';
      for (final command in _sentCommands) {
        content += '$command\n';
      }
      content += '\nReceived Commands:\n';
      for (final command in _receivedCommands) {
        content += '$command\n';
      }

      await file.writeAsString(content);

      print('Commands saved to $filePath');

      final apiUrl =
          'https://fls8oe8xp7.execute-api.ap-south-1.amazonaws.com/dev/nosh-test-S3?file_name=$fileNameAWS';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: content,
        headers: {
          'Content-Type': 'text/plain'
        }, // Specify content type as text/plain
      );

      if (response.statusCode == 200) {
        print('Commands sent to S3 successfully');
      } else {
        print(
            'Failed to send commands to S3. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving and sending commands: $e');
    }

    // Show a custom dialog indicating assembly failure
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text(
                  'Assembly Success',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'QR Data: ${widget.qrData}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Sent Commands:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sentCommands.length,
                    itemBuilder: (context, index) {
                      final sentCommand = _sentCommands[index];
                      return ListTile(
                        title: Text(
                          'Sent: $sentCommand',
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Received Commands:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _receivedCommands.length,
                    itemBuilder: (context, index) {
                      final receivedCommand = _receivedCommands[index];
                      return ListTile(
                        title: Text(
                          'Received: $receivedCommand',
                          style: TextStyle(color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyPusher()),
                      (route) => false, // Remove all routes until the new route
                    );
                    // Navigate to MyPusher page
                  },
                  child: Text('OK', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.qrData),
      ),
      body: Column(
        children: [
          SizedBox(height: 20), // Add spacing

          // Scrollable container for commands
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _sentCommands.length + _receivedCommands.length,
                itemBuilder: (context, index) {
                  if (index % 2 == 0) {
                    // Display sent command
                    final sentIndex = index ~/ 2;
                    if (sentIndex < _sentCommands.length) {
                      final sentCommand = _sentCommands[sentIndex];
                      return ListTile(
                        title: Text('Sent: $sentCommand'),
                        // You can customize the ListTile appearance here
                      );
                    }
                  } else {
                    // Display received command
                    final receivedIndex = index ~/ 2;
                    if (receivedIndex < _receivedCommands.length) {
                      final receivedCommand = _receivedCommands[receivedIndex];
                      return ListTile(
                        title: Text('Received: $receivedCommand'),
                        // You can customize the ListTile appearance here
                      );
                    }
                  }
                  return SizedBox
                      .shrink(); // If index is out of bounds, return empty SizedBox
                },
              ),
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
            backgroundColor: _isPlaying ? Colors.red : Colors.green,
            child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}







  // void _waitForResponseAfterCmdA002() {
  //   // Set a flag to indicate waiting for response
  //   bool waitingForResponse = true;

  //   // Start a timer to stop waiting after 6 seconds
  //   Timer(Duration(seconds: 8), () {
  //     // Stop waiting after 6 seconds
  //     waitingForResponse = false;
  //   });

  //   _port!.inputStream!.listen((Uint8List data) async {
  //     if (!waitingForResponse || !mounted)
  //       return; // Check mounted before setState

  //     if (data.isNotEmpty) {
  //       final response = String.fromCharCodes(data).trim();
  //       print('Received response: $response');

  //       if (response.trim() == '0') {
  //         // Received expected response, stop waiting
  //         waitingForResponse = false;

  //         // Process the response or perform any necessary actions
  //         print('Received expected response: $response');

  //         // _showCheckContainer(); // Display the "Check 1" container
  //         await Future.delayed(Duration(seconds: 1));
  //         final command = 'CMD A 003\r\n';
  //         _port!.write(Uint8List.fromList(command.codeUnits));
  //         setState(() {
  //           _sentCommands.add(command);
  //         });
  //         _scrollToBottom();
  //         _waitForResponseAfterCmdA003();
  //       } else if (response.trim() == '-101') {
  //         _stopPlaying();
  //       }
  //     }
  //   });
  // }

  // void _waitForResponseAfterCmdA003() {
  //   // Set a flag to indicate waiting for response
  //   bool waitingForResponse = true;

  //   // Start a timer to stop waiting after 6 seconds
  //   Timer(Duration(seconds: 8), () {
  //     // Stop waiting after 6 seconds
  //     waitingForResponse = false;
  //   });

  //   _port!.inputStream!.listen((Uint8List data) async {
  //     if (!waitingForResponse || !mounted)
  //       return; // Check mounted before setState

  //     if (data.isNotEmpty) {
  //       final response = String.fromCharCodes(data).trim();
  //       print('Received response: $response');

  //       if (response.trim() == '0') {
  //         // Received expected response, stop waiting
  //         waitingForResponse = false;

  //         // Process the response or perform any necessary actions
  //         print('Received expected response: $response');

  //         // _showCheckContainer(); // Display the "Check 1" container
  //         await Future.delayed(Duration(seconds: 1));
  //         final command = 'CMD A 004\r\n';
  //         _port!.write(Uint8List.fromList(command.codeUnits));
  //         setState(() {
  //           _sentCommands.add(command);
  //         });
  //         _scrollToBottom();
  //         _waitForResponseAfterCmdA004();
  //       } else if (response.trim() == '-101') {
  //         _stopPlaying();
  //       }
  //     }
  //   });
  // }

  // void _waitForResponseAfterCmdA004() {
  //   // Set a flag to indicate waiting for response
  //   bool waitingForResponse = true;

  //   // Start a timer to stop waiting after 6 seconds
  //   Timer(Duration(seconds: 8), () {
  //     // Stop waiting after 6 seconds
  //     waitingForResponse = false;
  //   });

  //   _port!.inputStream!.listen((Uint8List data) async {
  //     if (!waitingForResponse || !mounted)
  //       return; // Check mounted before setState

  //     if (data.isNotEmpty) {
  //       final response = String.fromCharCodes(data).trim();
  //       print('Received response: $response');
  //       await Future.delayed(Duration(seconds: 1));

  //       if (response.trim() == '0') {
  //         // Received expected response, stop waiting
  //         waitingForResponse = false;

  //         // Process the response or perform any necessary actions
  //         print('Received expected response: $response');
         

  //         // _showCheckContainer(); // Display the "Check 1" container

  //         // final command = 'CMD A 003\r\n';
  //         // _port!.write(Uint8List.fromList(command.codeUnits));
  //         // setState(() {
  //         //   _sentCommands.add(command);
  //         // });
  //         // _scrollToBottom();
  //         // _waitForResponseAfterCmdA003();
  //       } else if (response.trim() == '-101') {
  //         _stopPlaying();
  //       }
  //     }
  //   });
  // }
