import 'package:flutter/material.dart';
import '../models/user.dart';
import 'messages_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final List<User> chats = [
    User(
      id: 'driver',
      name: 'Van Driver',
      avatarText: 'D',
      lastMessage: 'See you tomorrow!',
    ),
    User(
      id: 'school',
      name: 'School Administration',
      avatarText: 'S',
      lastMessage: 'Your van schedule has been updated.',
    ),
    User(
      id: 'group',
      name: 'Van Group Chat',
      avatarText: 'G',
      isGroup: true,
      lastMessage: 'Thanks for the ride!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: chat.isGroup ? Colors.green : Colors.deepPurple,
              child: Text(
                chat.avatarText ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              chat.lastMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(user: chat),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
