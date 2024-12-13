import 'package:attandance_management_app/Student/addStudents.dart';
import 'package:attandance_management_app/Student/studetnList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Add this package for floating action button animations

import '../Attendance/MarkAttendance.dart';
import '../Attendance/ViewAttendance.dart';
import '../teacher/addTeacher.dart';
import '../teacher/teacherList.dart';

class SchoolDashboard extends StatefulWidget {
  @override
  _SchoolDashboardState createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  int _selectedIndex = 0;
  int totalStudents = 0;
  int totalTeachers = 0;
  String schoolId = "";
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
    fetchSchoolData().then((_) {
      if (schoolId.isNotEmpty) {
        fetchStatistics(schoolId);
      }
    });
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
        schoolId = querySnapshot.docs.first.id; // Get the school ID
        print("School ID: $schoolId");
        setState(() {
          schoolName = schoolData['SchoolName'] ?? "Unknown School";
        });
        // Store schoolId for later use (pass it to AddStudents)
        // You can store it in a class-level variable or pass it directly where needed
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

  Future<void> fetchStatistics(String schoolId) async {
    if (schoolId.isEmpty) {
      print("Error: schoolId is empty. Cannot fetch statistics.");
      return;
    }
    try {
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Students')
          .get();

      final teachersSnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Teachers')
          .get();

      setState(() {
        totalStudents = studentsSnapshot.size;
        totalTeachers = teachersSnapshot.size;
        dailyAttendancePercentage = 87.5; // Example value
        pendingFees = 25000.0; // Example value
      });

      print("Total students: $totalStudents");
      print("Total teachers: $totalTeachers");
    } catch (e) {
      print("Error fetching statistics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, $schoolName",
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchSchoolData();
          await fetchStatistics(schoolId);
        },
        child: _selectedIndex == 0
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Key Statistics",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final List<Map<String, dynamic>> stats = [
                          {
                            "title": "Total Students",
                            "value": totalStudents.toString(),
                            "icon": Icons.group,
                            "color": Colors.blue,
                            "onTap": () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StudentListPage(schoolID: schoolId),
                                ),
                              );
                            },
                          },
                          {
                            "title": "Total Teachers",
                            "value": totalTeachers.toString(),
                            "icon": Icons.person,
                            "color": Colors.green,
                            "onTap": () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherListPage(schoolID: schoolId),
                                ),
                              );
                            },
                          },
                          {
                            "title": "Attendance",
                            "value":
                                "${dailyAttendancePercentage.toStringAsFixed(1)}% Present",
                            "icon": Icons.check_circle_outline,
                            "color": Colors.orange,
                          },
                          {
                            "title": "Pending Fees",
                            "value": "₹${pendingFees.toStringAsFixed(2)}",
                            "icon": Icons.monetization_on,
                            "color": Colors.red,
                          },
                        ];

                        return _buildStatisticCard(
                          stats[index]['title'],
                          stats[index]['value'],
                          stats[index]['icon'],
                          stats[index]['color'],
                          onTap: stats[index]['onTap'],
                        );
                      },
                    ),
                  ],
                ),
              )
            : _widgetOptions.elementAt(_selectedIndex),
      ),
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: Icon(Icons.person_add),
            label: "Add Student",
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStudents(
                    schoolID: schoolId,
                    onStudentAdded: () {
                      fetchStatistics(schoolId);
                    },
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.person_outline),
            label: "Add Teacher",
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTeacherPage(
                    schoolID: schoolId,
                    onTeacherAdded: () {
                      fetchStatistics(
                          schoolId); // Refresh statistics immediately
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(
      String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
