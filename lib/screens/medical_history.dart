import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalHistory extends StatefulWidget {
  final String userName;
  final String title;
  final String docId;

  const MedicalHistory({
    Key? key,
    required this.userName,
    required this.title,
    required this.docId,
  }) : super(key: key);

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  final _formKey = GlobalKey<FormState>();
  String _disease = '';
  String _description = '';

  Future<void> _addMedicalHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🩺 Add Medical Record",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Disease Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _disease = val!,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _description = val!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A148C)),
            child: const Text("Save"),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final newRecord = {
                  'timestamp': Timestamp.now(),
                  'disease': _disease,
                  'description': _description,
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.docId)
                    .update({
                  'medical_history': FieldValue.arrayUnion([newRecord])
                });

                Navigator.of(context).pop();
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.docId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        title: Text(
          "${widget.title} of ${widget.userName}",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final history = (data?['medical_history'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/mhistory2.png', height: 250),
                  const SizedBox(height: 20),
                  const Text(
                    "No Records Found",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text("Tap the ➕ button to add one."),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: GridView.builder(
              itemCount: history.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = history[index];
                final timeStamp = item['timestamp'] as Timestamp?;

                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.grey,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (timeStamp != null)
                        Text(
                          _formatDate(timeStamp),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        item['disease'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['description'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMedicalHistory,
        backgroundColor: const Color.fromARGB(255, 163, 141, 202),
        icon: const Icon(Icons.add),
        label: const Text("Add Record"),
      ),
    );
  }
}
