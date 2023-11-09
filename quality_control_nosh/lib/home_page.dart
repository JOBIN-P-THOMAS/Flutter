// ignore_for_file: use_key_in_widget_constructors, sort_child_properties_last, prefer_const_constructors, sized_box_for_whitespace, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:quality_control_nosh/inside_home.dart';
// import 'asssembly_pusher.dart';
// import 'package:quality_control_nosh/assembly_start.dart';
import 'qr_code_scanner_screen.dart'; // Added import for QR code scanner screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nosh QC Testing',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  List<String> selectedValues = [];
  List<String> options = [
    'PLATFORM',
    'PUSHER',
    'STIRRER',
    'WATER',
    'OIL',
    'SPICE'
  ];
  bool allowZeroSelection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Nosh QC Testing'),
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Settings'),
                  value: 'Settings',
                ),
              ];
            },
            onSelected: (String value) {
              if (value == 'Settings') {
                _showSettingsDialog(context);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 20,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Text(
            'dlmf c',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        tooltip: 'Scan QR Code',
        child: Icon(Icons.qr_code),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Settings'),
            content: Column(
              children: [
                Container(
                  height: 400,
                  child: HomePageContent(),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );
  }
}

/*
  the contents inside the settings page saving the the person data to the excell etc are present here

*/
class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20), // Adjusted SizedBox height

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email ID',
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10), // Added SizedBox for spacing

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              height: 40,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name',
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10), // Added SizedBox for spacing

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              height: 40,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Employee ID',
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10), // Added SizedBox for spacing

          DropdownButtonWidget(),
        ],
      ),
    );
  }
}

class DropdownButtonWidget extends StatefulWidget {
  @override
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  List<String> selectedValues = [];
  List<String> options = [
    'PLATFORM',
    'PUSHER',
    'STIRRER',
    'WATER',
    'OIL',
    'SPICE'
  ];
  bool allowZeroSelection = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              value: selectedValues.isNotEmpty ? selectedValues.first : null,
              onChanged: allowZeroSelection
                  ? (String? value) {
                      setState(() {
                        if (selectedValues.contains(value)) {
                          selectedValues.remove(value);
                        } else {
                          selectedValues.add(value!);
                        }
                      });
                    }
                  : null,
              hint: Text("Select the assembly"),

              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),

              icon: Icon(Icons.arrow_drop_down), // Add an icon
              style: TextStyle(fontSize: 16), // Increase font size
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // SizedBox(height: 10),
        // Row(
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.all(10),
        //       child: Checkbox(
        //         value: allowZeroSelection,
        //         onChanged: (bool? value) {
        //           setState(() {
        //             allowZeroSelection = value!;
        //             if (!allowZeroSelection && selectedValues.isEmpty) {
        //               selectedValues.add(options.first);
        //             }
        //           });
        //         },
        //       ),
        //     ),
        //     Text('CONNECT USB '),
        //   ],
        // ),
        // Padding(
        // padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        // child: GestureDetector(
        //   onTap: () {
        //     if (selectedValues.isNotEmpty) {
        //       String assemblyName = selectedValues.first;
        //       if (assemblyName == 'STIRRER') {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   AssemblyDetailPageStirrer(assemblyName)),
        //         );
        //       } else if (assemblyName == 'PUSHER') {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   AssemblyDetailPagePusher(assemblyName)),
        //         );
        //       }
        //       //  else (printf('hi');)// Add more conditions for other assemblies as needed
        //     }
        //   },
        //     child: Container(
        //       padding: EdgeInsets.all(14),
        //       decoration: BoxDecoration(
        //           color: Colors.orange,
        //           borderRadius: BorderRadius.circular(10)),
        //       child: Center(
        //           child: Text(
        //         "ENTER TESTING SETUP",
        //         style: TextStyle(
        //           color: Colors.black,
        //         ),
        //       )),
        //     ),
        //   ),
        // ),
        // SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: MaterialButton(
            onPressed: () {},
            color: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'Save',
              ),
            ),
          ),
        ),
        Center(
          child: MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            color: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              'sign out',
            ),
          ),
        ),
      ],
    );
  }
}
