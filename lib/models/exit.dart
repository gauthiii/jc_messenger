import 'dart:io';

import 'package:flutter/material.dart';

exitButton(context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Are you sure??",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: const Text("Click yes to exit App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              actions: [
                TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text("Yes",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: "Poppins-Regular",
                            fontWeight: FontWeight.bold,
                            color: Colors.blue))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: "Poppins-Regular",
                            fontWeight: FontWeight.bold,
                            color: Colors.red))),
              ]));
}
