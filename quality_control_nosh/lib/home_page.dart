// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quality_control_nosh/assembly_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'qr_code_scanner_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //app bar
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nosh QC Testing',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  late SharedPreferences prefs;
  late String? selectedAssembly = 'Select an assembly';

  @override
  void initState() {
    super.initState();
    _loadSavedAssembly();
  }

  _loadSavedAssembly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAssembly = prefs.getString('selectedAssembly');
    if (savedAssembly != null) {
      setState(() {
        selectedAssembly = savedAssembly; // Update selectedAssembly
      });
    }
  }

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
      body: Column(
        children: [
          SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: GestureDetector(
          //     onTap: _scanQRCode,
          //     child: Container(
          //       padding: EdgeInsets.all(16),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15),
          //         color: Colors.orange,
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             'Tap to Scan Assembly QR',
          //             style: TextStyle(color: Colors.white, fontSize: 18.0),
          //           ),
          //           Icon(
          //             Icons.qr_code,
          //             color: Colors.white,
          //             size: 30,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.red], // Choose your colors
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Enter Your Details and select an assembly to continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
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
                  child: SettingsPageContent(
                    selectedAssembly:
                        selectedValues.isNotEmpty ? selectedValues.first : null,
                    onAssemblyChanged: (String? newValue) {
                      setState(() {
                        selectedValues = [newValue!];
                      });
                    },
                  ),
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

  // void _scanQRCode() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
  //   );
  // }
}

class SettingsPageContent extends StatelessWidget {
  final String? selectedAssembly;
  final Function(String?) onAssemblyChanged;
  const SettingsPageContent({
    Key? key,
    required this.selectedAssembly,
    required this.onAssemblyChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
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
          SizedBox(height: 10),
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
          SizedBox(height: 10),
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
          SizedBox(height: 10),
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
  late String? selectedAssembly;

  @override
  void initState() {
    super.initState();
    _loadSavedAssembly();
  }

  _loadSavedAssembly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAssembly = prefs.getString('selectedAssembly');

    setState(() {
      selectedValues = savedAssembly != null ? [savedAssembly] : [];
      selectedAssembly =
          selectedValues.isNotEmpty && options.contains(savedAssembly)
              ? savedAssembly
              : options.isNotEmpty
                  ? options.first
                  : null;
    });
  }

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
            child: DropdownButtonFormField<String?>(
              value: selectedAssembly,
              onChanged: allowZeroSelection
                  ? (String? value) {
                      setState(() {
                        selectedAssembly = value;
                        if (selectedValues.contains(value)) {
                          selectedValues.remove(value);
                        } else {
                          selectedValues = [value!];
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
              icon: Icon(Icons.arrow_drop_down),
              style: TextStyle(fontSize: 16),
              items: options.map<DropdownMenuItem<String?>>((String value) {
                return DropdownMenuItem<String?>(
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: MaterialButton(
            onPressed: () {
              _saveSelectedAssembly();
              _showSnackbar();
            },
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

  _saveSelectedAssembly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedAssembly =
        selectedValues.isNotEmpty ? selectedValues.first : '';

    prefs.setString('selectedAssembly', savedAssembly);

    // Update the selectedAssembly in the state
    setState(() {
      selectedAssembly = savedAssembly;
    });

    // Navigate to the corresponding page based on the selected assembly
    switch (savedAssembly) {
      case 'STIRRER':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssemblyDetailPageStirrer(savedAssembly),
          ),
        );
        break;
      // Add cases for other assemblies if needed

      default:
      // Do nothing or handle the case where no specific page is needed
    }
  }

  _showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assembly saved: ${selectedValues.first}',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Close the dialog
    Navigator.of(context).pop();
  }
}
