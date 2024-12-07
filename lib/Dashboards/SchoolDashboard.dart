import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SchoolDashboard extends StatefulWidget {
  @override
  _SchoolDashboardState createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child:
          const Text(
            "Register Your School",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              color: Color( 0xFF000000),
              fontWeight: FontWeight.bold,
            ),
          ),)
    );
  }
}
