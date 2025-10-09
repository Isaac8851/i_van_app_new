import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class StudentList extends StatelessWidget {
  const StudentList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('students')
              .where(
                'driverId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data?.docs ?? [];
        if (students.isEmpty) {
          return const Center(child: Text('No students assigned'));
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index].data() as Map<String, dynamic>;
            return StreamBuilder<int>(
              stream: context.read<ChatService>().getUnreadCount(
                student['id'] ?? student['userId'] ?? '',
              ),
              builder: (context, unreadSnapshot) {
                final unreadCount = unreadSnapshot.data ?? 0;
                return ListTile(
                  leading: CircleAvatar(child: Text(student['name'][0])),
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  trailing:
                      unreadCount > 0
                          ? CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                          : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              chatId: student['id'] ?? student['userId'] ?? '',
                              chatTitle: student['name'],
                            ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
