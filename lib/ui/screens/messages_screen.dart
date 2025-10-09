import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Active Chats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildChatTile(
            context,
            'Driver: Mike Rodriguez',
            'Trip TRP_20240821_001',
            'driver_chat_001',
            Icons.directions_car,
            Colors.blue,
          ),
          _buildChatTile(
            context,
            'Support Team',
            'Get help with any issues',
            'support_chat',
            Icons.support_agent,
            Colors.orange,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMessageTile(
            'Mike Rodriguez',
            'I\'ll be there in 5 minutes',
            '2 min ago',
            Icons.directions_car,
          ),
          _buildMessageTile(
            'Support Team',
            'Your trip has been confirmed',
            '1 hour ago',
            Icons.support_agent,
          ),
          _buildMessageTile(
            'System',
            'Trip TRP_20240821_001 scheduled for 7:30 AM',
            '2 hours ago',
            Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    String title,
    String subtitle,
    String chatId,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                chatTitle: title,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageTile(
    String sender,
    String message,
    String time,
    IconData icon,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Icon(icon, color: Colors.grey.shade600),
      ),
      title: Text(sender),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
    );
  }
}
