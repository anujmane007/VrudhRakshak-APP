import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vrudharakshak/screens/ExerciseEncouragement.dart';
import 'package:vrudharakshak/screens/Family/CaregiverInvolvement.dart';
import 'package:vrudharakshak/screens/HealthMonitoringScreen.dart';
import 'package:vrudharakshak/screens/login_screen.dart';
import 'package:vrudharakshak/screens/medical_history.dart';
import 'package:vrudharakshak/screens/notification.dart';
import 'package:vrudharakshak/screens/profile_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  String docId;

  HomeScreen({Key? key, required this.userName, required this.docId})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildMainContent(),
      CaregiverInvolvement(),
      ProfileScreen(userId: widget.docId),
    ];
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0FA),
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A148C),
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Care'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('images/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '👋 Hi ${widget.userName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildMenuCard(
                title: 'Medical History',
                iconPath: 'images/mhistory.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalHistory(
                        userName: widget.userName,
                        title: "Medical History",
                        docId: widget.docId,
                      ),
                    ),
                  );
                },
              ),
              _buildMenuCard(
                title: 'Daily Reminder',
                iconPath: 'images/dailyrem.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NotificationForm(userId: widget.docId))),
              ),
              _buildMenuCard(
                title: 'Health Monitoring',
                iconPath: 'images/hmonitor.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthMonitoringScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                title: 'Family and Caregiver',
                iconPath: 'images/fandcar.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaregiverInvolvement()),
                ),
              ),
              _buildMenuCard(
                title: 'Exercise Encouragement',
                iconPath: 'images/eande.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Exerciseencouragement()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      {required String title,
      required String iconPath,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        shadowColor: Colors.deepPurple.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A148C),
                  ),
                ),
              ),
              Image.asset(
                iconPath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String imageUrl = userData['profileImage'] ?? '';
            return ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('images/avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.deepPurple),
                  title: const Text("Home"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: const Text("Profile"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: widget.docId),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: logout,
                ),
                // ListTile(
                //   leading: const Icon(Icons.settings, color: Colors.grey),
                //   title: const Text("Settings"),
                //   onTap: () {},
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
