import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Attendance/MarkAttendance.dart';
import '../Attendance/ViewAttendance.dart';

class SchoolDashboard extends StatefulWidget {
  @override
  _SchoolDashboardState createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  int _selectedIndex = 0;
  int totalStudents = 0;
  int totalTeachers = 0;
  double pendingFees = 0.0;
  double dailyAttendancePercentage = 0.0;
  String schoolName = "Loading...";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final List<Widget> _widgetOptions = <Widget>[
    Center(child: Text("Dashboard Content")),
    const MarkAttendance(),
    ViewAttendance(),
    Center(child: Text("Profile Content")),
  ];

  @override
  void initState() {
    super.initState();
    fetchSchoolData();
    fetchStatistics();
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchSchoolData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        setState(() {
          schoolName = "No user logged in!";
        });
        return;
      }

      String userEmail = user.email!;
      print("Logged in user's email: $userEmail");

      // Query Firestore for the school with the matching email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .where('ContactInfo.Email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var schoolData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          schoolName = schoolData['SchoolName'] ?? "Unknown School";
        });
      } else {
        setState(() {
          schoolName = "School not found!";
        });
      }
    } catch (e) {
      setState(() {
        schoolName = "Error fetching data!";
      });
      print("Error: $e");
    }
  }

  Future<void> fetchStatistics() async {
    try {
      // Replace these Firebase queries with actual logic to fetch data
      final studentsSnapshot =
      await FirebaseFirestore.instance.collection('Students').get();
      final teachersSnapshot =
      await FirebaseFirestore.instance.collection('Teachers').get();

      // Dummy data for attendance and fees
      final dailyAttendance = 87.5;
      final totalPendingFees = 25000.0;

      setState(() {
        totalStudents = studentsSnapshot.size;
        totalTeachers = teachersSnapshot.size;
        dailyAttendancePercentage = dailyAttendance;
        pendingFees = totalPendingFees;
      });
    } catch (e) {
      print("Error fetching statistics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, $schoolName",
        ),
      ),
      body: _selectedIndex == 0
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Key Statistics",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Wrap GridView in a SizedBox to prevent infinite height issue
              SizedBox(
                height: screenHeight * 0.5, // Adjust the height dynamically
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true, // Prevents GridView from taking infinite height
                  physics: NeverScrollableScrollPhysics(), // Disables GridView scrolling
                  children: [
                    _buildStatisticCard(
                      "Total Students",
                      totalStudents.toString(),
                      Icons.group,
                      Colors.blue,
                    ),
                    _buildStatisticCard(
                      "Total Teachers",
                      totalTeachers.toString(),
                      Icons.person,
                      Colors.green,
                    ),
                    _buildStatisticCard(
                      "Attendance",
                      "${dailyAttendancePercentage.toStringAsFixed(1)}% Present",
                      Icons.check_circle_outline,
                      Colors.orange,
                    ),
                    _buildStatisticCard(
                      "Pending Fees",
                      "₹${pendingFees.toStringAsFixed(2)}",
                      Icons.monetization_on,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "Mark Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.green,
        onTap: _onTap,
      ),
    );
  }

  Widget _buildStatisticCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
