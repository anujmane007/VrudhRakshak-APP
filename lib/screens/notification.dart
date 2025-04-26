import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationForm extends StatefulWidget {
  final String userId;

  const NotificationForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedPurpose;

  final purposes = [
    "Take Medicine",
    "Doctor Appointment",
    "Health Checkup",
    "Family Meeting",
    "Daily Exercise",
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Please complete all fields", style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final reminderDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('reminders')
          .add({
        'purpose': selectedPurpose,
        'datetime': reminderDateTime,
        'notificationId': notificationId,
        'createdAt': Timestamp.now(),
      });

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'booking_channel',
          title: 'Reminder: $selectedPurpose',
          body: 'It\'s time for your $selectedPurpose!',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: reminderDateTime.year,
          month: reminderDateTime.month,
          day: reminderDateTime.day,
          hour: reminderDateTime.hour,
          minute: reminderDateTime.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
        ),
      );

      print("Notification Scheduled for: $reminderDateTime");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reminder saved successfully!",
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedDate = null;
        selectedTime = null;
        selectedPurpose = null;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Error saving reminder: $e", style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteReminder(String docId, int notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('reminders')
          .doc(docId)
          .delete();

      await AwesomeNotifications().cancel(notificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reminder deleted successfully!",
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<QuerySnapshot> _getReminders() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('reminders')
        .orderBy('datetime')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Reminder", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(selectedDate == null
                    ? "Pick a Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                onTap: _pickDate,
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(selectedTime == null
                    ? "Pick a Time"
                    : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"),
                onTap: _pickTime,
              ),
              DropdownButtonFormField<String>(
                value: selectedPurpose,
                items: purposes
                    .map((purpose) => DropdownMenuItem(
                          value: purpose,
                          child: Text(purpose),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPurpose = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Purpose",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Save Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 30),
              Text("Saved Reminders", style: GoogleFonts.poppins(fontSize: 18)),
              StreamBuilder<QuerySnapshot>(
                stream: _getReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No reminders found.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var reminder = snapshot.data!.docs[index];
                      var reminderData =
                          reminder.data() as Map<String, dynamic>;

                      DateTime reminderDateTime =
                          (reminderData['datetime'] as Timestamp).toDate();

                      final notificationId =
                          reminderData['notificationId'] ?? 0;

                      return ListTile(
                        leading: Icon(Icons.alarm),
                        title: Text(reminderData['purpose']),
                        subtitle: Text(
                            "${reminderDateTime.day}/${reminderDateTime.month}/${reminderDateTime.year} ${reminderDateTime.hour}:${reminderDateTime.minute.toString().padLeft(2, '0')}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteReminder(reminder.id, notificationId);
                          },
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
