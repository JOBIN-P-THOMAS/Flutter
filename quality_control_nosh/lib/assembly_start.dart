import 'package:flutter/material.dart';
import 'package:quality_control_nosh/qr_code_scanner_screen.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class AssemblyDetailPageStirrer extends StatefulWidget {
  final String assemblyName;

  AssemblyDetailPageStirrer(this.assemblyName);

  @override
  _AssemblyDetailPageStirrerState createState() =>
      _AssemblyDetailPageStirrerState();
}

class _AssemblyDetailPageStirrerState extends State<AssemblyDetailPageStirrer> {
  bool _showQRCodeMessage = false;
  UsbPort? port;
  String response = '';
  TextEditingController commandController = TextEditingController();
  int selectedBaudRate = 38400;
  bool isPortOpen = false;
  String scannedQRCode = ''; // Scanned QR code data
  int currentCheckIndex = 0;
  List<String> commandLogs = [];
  final ScrollController _scrollController = ScrollController();

  bool _stopButtonPressed = false;

  List<bool> checkStatus = List.filled(6, false); // Initialize with false

  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    _initUsbCommunication(); // Initiate USB connection during widget initialization

    // Retrieve saved QR code data when the widget is initialized
    _retrieveSavedQRData();
  }

  void addToCommandLogs(String log) {
    setState(() {
      commandLogs.add(log);
    });

    // Scroll to the bottom
    _scrollToBottom();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel(); // Cancel the timer when the widget is disposed
    port?.close(); // Close the USB port when the widget is disposed
    super.dispose();
  }

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
            addToCommandLogs('Received: $line');
          });
        }
      });
      setState(() {
        isPortOpen = true;
      });
      _showPopupMessage('Connected');
      _connectionTimer?.cancel(); // Stop the connection timer if connected
    }
  }

  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!isPortOpen) {
        _initUsbCommunication();
      } else {
        timer.cancel(); // Stop the timer once the connection is successful
      }
    });
  }

  void _togglePortConnection() {
    if (isPortOpen) {
      port!.close();
      setState(() {
        isPortOpen = false;
      });
      _showPopupMessage('Disconnected');
    } else {
      _startConnectionTimer(); // Start the connection timer
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
      {'command': 'CMD A', 'expectedResponse': '0'},
      {'command': 'CMD B', 'expectedResponse': '0'},
      {'command': 'CMD C', 'expectedResponse': '0'},
      {'command': 'CMD D', 'expectedResponse': '0'},
    ];

    for (int j = 0; j < 2; j++) {
      for (var i = 0; i < commands.length; i++) {
        if (_stopButtonPressed) {
          // Stop button pressed, exit the loop
          _stopButtonPressed = false; // Reset the flag
          break;
        }

        if (!isPortOpen) {
          // Check again if the port is still open before sending the command
          _showPopupMessage('USB port is not open.');
          break;
        }
        final command = commands[i]['command'];
        final expectedResponse = commands[i]['expectedResponse'];

        if (command != null) {
          // Send the command
          await _sendCommandTwice(command);

          final responseTimeout = Duration(seconds: 3);
          final response =
              await _waitForResponse(expectedResponse!, responseTimeout);

          if (response != expectedResponse && response != '\$STATUS: 0') {
            _updateCheckStatus(i, false);
            _showPopupMessage('Assembly failed. Response: $response');
            return; // Stop further command execution if the response is not as expected
          } else {
            _updateCheckStatus(i, true);

            // Show the next check container
            setState(() {
              currentCheckIndex = i + 1;
            });

            // Delay for better visualization (optional)
            await Future.delayed(Duration(seconds: 1));
          }
        }
      }
    }

    if (checkStatus.every((check) => check)) {
      _showPopupMessage('All checks completed.');
    }
  }

// Function to send a command twice with a 100ms delay
  Future<void> _sendCommandTwice(String command) async {
    await port!.write(Uint8List.fromList(command.codeUnits));
    addToCommandLogs('Sent: $command');

    // Wait for 100ms before sending the command again
    // await Future.delayed(Duration(milliseconds: 100));

    await port!.write(Uint8List.fromList(command.codeUnits));
    addToCommandLogs('Sent: $command');

    // Scroll to the bottom after sending the command twice
    _scrollToBottom();
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
    setState(() {
      _stopButtonPressed = true;
    });
    _showEmergencyStopPopup();
    // Add any necessary actions for the stop button here
  }

  void _restartButtonAction() {
    // Clear logs and reset state
    _clearLogs();
    setState(() {
      currentCheckIndex = 0;
      scannedQRCode = '';
      checkStatus = List.filled(6, false);
    });

    // Start the process again by calling the start button action.
    _startButtonAction();
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
          _showQRCodeMessage =
              true; // Set to true to display the QR code message
          // Start a timer to hide the QR code message after 1 minute
          Future.delayed(Duration(minutes: 1), () {
            setState(() {
              _showQRCodeMessage = false;
            });
          });
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: _scanQRCode,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.orange[700],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scan QR to start',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
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
                currentCheckIndex == 0
                    ? _buildStartCheckContainer()
                    : _buildCheckContainer('Safety Check', checkStatus[0]),
                if (currentCheckIndex >= 1)
                  _buildCheckContainer('Left Check', checkStatus[1]),
                if (currentCheckIndex >= 2)
                  _buildCheckContainer('Right Check', checkStatus[2]),
                if (currentCheckIndex >= 3)
                  _buildCheckContainer('Encoder Check', checkStatus[3]),
                if (currentCheckIndex >= 4)
                  _buildCheckContainer('Assembly Smooth Check', checkStatus[4]),
                SizedBox(
                    height:
                        10), // Add some space between check containers and command logs
              ],
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                // Wrap with SingleChildScrollView
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Command Logs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: ListView.builder(
                          // Removed SingleChildScrollView wrapping from here
                          shrinkWrap: true,
                          reverse: true,
                          controller: _scrollController,
                          itemCount: commandLogs.length,
                          itemBuilder: (context, index) {
                            return Text(
                              commandLogs[index],
                              style: TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        // Floating action buttons
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: _startButtonAction,
              backgroundColor: Colors.green,
              child: Icon(Icons.play_arrow),
            ),
            FloatingActionButton(
              onPressed: _stopButtonAction,
              backgroundColor: Colors.red,
              child: Icon(Icons.stop),
            ),
            FloatingActionButton(
              onPressed: _togglePortConnection,
              backgroundColor: isPortOpen ? Colors.green : Colors.red,
              child: Icon(isPortOpen ? Icons.usb : Icons.usb_off),
            ),
            FloatingActionButton(
              onPressed: _restartButtonAction,
              backgroundColor: Colors.green,
              child: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartCheckContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_showQRCodeMessage) // Only show if the QR code message is set to be displayed
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Scanned QR Code: $scannedQRCode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          Container(
            height: 60,
            width: double.maxFinite,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // color: Colors.grey[400],
            ),
            child: Center(
              child: Text(
                'Press green play button to proceed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyStopPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Stop'),
          content: Text('The process has been stopped.'),
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

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _clearLogs() {
    setState(() {
      commandLogs.clear();
    });
    _scrollToBottom(); // Scroll to the bottom after clearing logs
  }

  // Function to save scanned QR code data
  Future<void> _saveQRData(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('scannedQRData', data);
  }

  // Function to retrieve saved QR code data
  Future<void> _retrieveSavedQRData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedQRData = prefs.getString('scannedQRData') ?? '';
    setState(() {
      scannedQRCode = savedQRData;
    });
  }
}
