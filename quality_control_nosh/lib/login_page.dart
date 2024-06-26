// ignore_for_file: prefer_const_constructors, file_names, prefer_const_literals_to_create_immutables, use_build_context_synchronously, duplicate_ignore, dangling_library_doc_comments
//ignooo
// import 'dart:html';
///

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Sign in successful, you can handle it here
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,

        ///#$
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor:
                const Color.fromARGB(255, 236, 97, 55), // Light orange color
            title: Center(
              child: Text(
                'Invalid Credentials',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            content: Text('Try to contact Nosh'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 233, 233),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Hello Again!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 40),

                //Nosh Logo
                Center(child: Image.asset('lib/assets/logo.png')),

                //nosh production qc
                Text(
                  'Production QC DBMS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 20),

                //sign in container email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 220, 214, 214),
                        border: Border.all(
                            color: const Color.fromARGB(26, 216, 213, 213)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email - try - test@gmail.com"),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //signin container password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 220, 214, 214),
                        border: Border.all(
                            color: const Color.fromARGB(26, 216, 213, 213)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password - try - 12345678"),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //sign in
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 236, 97, 55),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                //new user
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Contact Nosh"),
                              content: Text("Phone Number: "),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "Close",
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        " contact Nosh",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
