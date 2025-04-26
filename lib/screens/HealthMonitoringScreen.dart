import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HealthMonitoringScreen extends StatelessWidget {
  const HealthMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Monitoring"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('EspData')
            .doc('PARA')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final ax = data['AX'] ?? 'N/A';
          final fall = data['FALL'] ?? '0';

          bool fallDetected = fall == "1";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AX Value: $ax", style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: fallDetected ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        fallDetected ? Icons.warning : Icons.check_circle,
                        color: fallDetected ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        fallDetected
                            ? "⚠️ Fall Detected!"
                            : "✅ No Fall Detected",
                        style: TextStyle(
                          fontSize: 18,
                          color: fallDetected ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
