import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vrudharakshak/firebase_options.dart';
import 'package:vrudharakshak/screens/home_screen.dart';
import 'package:vrudharakshak/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'booking_channel',
          channelName: 'Booking Notifications',
          channelDescription: 'Notifications for vrudhrakshak',
          defaultColor: Colors.blueAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ],
      debug: true);

  requestNotificationPermission();
  runApp(const MyApp());
}

void requestNotificationPermission() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartScreen() async {
    // Wait for auth state to load correctly
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        debugPrint("User Firestore Data: ${doc.data()}");

        final data = doc.data();
        final fullName = data?['fullName'] ?? 'User';

        return HomeScreen(
          userName: fullName,
          docId: user.uid,
        );
      } catch (e) {
        debugPrint("Firestore error: $e");
        return SplashScreen();
      }
    } else {
      return SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _determineStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
