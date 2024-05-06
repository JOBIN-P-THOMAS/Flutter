// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quality_control_nosh/Pusher/ui.dart';
import 'package:quality_control_nosh/Spice/ui_spice.dart';
// import 'package:quality_control_nosh/assembly_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quality_control_nosh/Platform/ui_platform.dart';
import 'package:quality_control_nosh/Stirrer/ui_stirrer.dart';
import 'package:quality_control_nosh/PCB/ui_pcb.dart';

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
    // 'WATER',
    // 'OIL',
    'SPICE',
    'PCB'
  ];
  bool allowZeroSelection = true;

  // late SharedPreferences prefs;
  late String? selectedAssembly = 'Select an assembly';
  late SharedPreferences prefs;
  // late String? selectedAssembly;
  late String? email;
  late String? name;
  late String? employeeId;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadSavedAssembly();
  }

  _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      name = prefs.getString('name');
      employeeId = prefs.getString('employeeId');
    });
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
                  child: Text('User'),
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
          // Expanded(
          //   child: Center(
          //     child: Container(
          //       padding: EdgeInsets.all(20),
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [Colors.orange, Colors.red], // Choose your colors
          //         ),
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: Text(
          //         'Enter Your Details and select an assembly to continue',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                //PLATFORM
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPlatform(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.maxFinite / 2,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PLATFORM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Adjust as needed
                          Image.asset(
                            'lib/assets/logo.png', // Replace with your image asset path
                            height: 130, // Adjust as needed
                            width: 130, // Adjust as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //Pusher
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPusher(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.maxFinite / 2,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PUSHER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Adjust as needed
                          Image.asset(
                            'lib/assets/logo.png', // Replace with your image asset path
                            height: 130, // Adjust as needed
                            width: 130, // Adjust as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                ///stirrer
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyStirrer(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.maxFinite / 2,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'STIRRER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Adjust as needed
                          Image.asset(
                            'lib/assets/logo.png', // Replace with your image asset path
                            height: 130, // Adjust as needed
                            width: 130, // Adjust as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

// //water
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AssemblyDetailPageStirrer('WATER'),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       height: double.maxFinite / 2,
//                       decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: Offset(0, 3), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'WATER',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 10), // Adjust as needed
//                           Image.asset(
//                             'lib/assets/logo.png', // Replace with your image asset path
//                             height: 130, // Adjust as needed
//                             width: 130, // Adjust as needed
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
// //OIL
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AssemblyDetailPageStirrer('Your Assembly Name'),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       height: double.maxFinite / 2,
//                       decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: Offset(0, 3), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'OIL',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 10), // Adjust as needed
//                           Image.asset(
//                             'lib/assets/logo.png', // Replace with your image asset path
//                             height: 130, // Adjust as needed
//                             width: 130, // Adjust as needed
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
                //Spice
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MySpice(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.maxFinite / 2,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SPICE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Adjust as needed
                          Image.asset(
                            'lib/assets/logo.png', // Replace with your image asset path
                            height: 130, // Adjust as needed
                            width: 130, // Adjust as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //PCB
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPcb(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.maxFinite / 2,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MAIN PCB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Adjust as needed
                          Image.asset(
                            'lib/assets/logo.png', // Replace with your image asset path
                            height: 130, // Adjust as needed
                            width: 130, // Adjust as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
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
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController employeeIdController;

  SettingsPageContent({
    Key? key,
    required this.selectedAssembly,
    required this.onAssemblyChanged,
  })  : emailController = TextEditingController(),
        nameController = TextEditingController(),
        employeeIdController = TextEditingController(),
        super(key: key) {
    _loadSavedData();
  }
  _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    nameController.text = prefs.getString('name') ?? '';
    employeeIdController.text = prefs.getString('employeeId') ?? '';
  }

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
                  controller: emailController,
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
                  controller: nameController,
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
                  controller: employeeIdController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Employee ID',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonWidget(
            emailController: emailController,
            nameController: nameController,
            employeeIdController: employeeIdController,
          ),
        ],
      ),
    );
  }
}

class DropdownButtonWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController employeeIdController;

  const DropdownButtonWidget({
    required this.emailController,
    required this.nameController,
    required this.employeeIdController,
  });

  @override
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  List<String> selectedValues = [];
  List<String> options = [
    'PLATFORM',
    'PUSHER',
    'STIRRER',
    // 'WATER',
    // 'OIL',
    'SPICE',
    'PCB'
  ];
  String? email = '';
  String? name = '';
  String? employeeId = '';

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
    prefs.setString('email', widget.emailController.text);
    prefs.setString('name', widget.nameController.text);
    prefs.setString('employeeId', widget.employeeIdController.text);

    setState(() {
      selectedAssembly = savedAssembly;
    });

    // Navigate to the corresponding page based on the selected assembly
    switch (savedAssembly) {
      case 'STIRRER':
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => AssemblyDetailPageStirrer(savedAssembly),
            builder: (context) => MyStirrer(),
          ),
        );
        break;
      case 'PUSHER':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPusher(),
          ),
        );
        break;
      case 'PLATFORM':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPlatform(),
          ),
        );
        break;
      case 'SPICE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MySpice(),
          ),
        );
        break;
      case 'PCB':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MySpice(),
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
