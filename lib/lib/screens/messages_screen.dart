import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';

class MessagesScreen extends StatefulWidget {
  final User user;

  const MessagesScreen({super.key, required this.user});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Preset responses for different users
  final Map<String, Map<String, String>> userResponses = {
    'driver': {
      'where are you?': 'Be there in 5 minutes!',
      'hello': 'Hi! How can I help you today?',
      'what time will you arrive?':
          'I will arrive at the usual pickup point at 8:00 AM.',
      'are you near?': 'Yes, I\'m just around the corner!',
      'i\'m running late': 'No problem, I\'ll wait for you.',
      'can you wait 5 minutes?': 'Sure, take your time!',
    },
    'school': {
      'hello': 'Hello! How can we assist you today?',
      'what time does school start?': 'School starts at 8:00 AM sharp.',
      'is the van service available today?':
          'Yes, the van service is running as scheduled.',
      'can i change my pickup time?':
          'Please submit a formal request through the administration office.',
    },
    'group': {
      'hello everyone': 'Hi! Welcome to the van group chat!',
      'who\'s taking the van today?': 'I am! See you all there.',
      'is anyone running late?': 'All on schedule so far!',
      'what time is pickup tomorrow?':
          'Regular time - 7:30 AM at the usual spots.',
    },
  };

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(
        Message(text: text, isUser: true, timestamp: DateTime.now()),
      );

      // Check for preset response based on user type
      final responses = userResponses[widget.user.id];
      if (responses != null) {
        String? response = responses[text.toLowerCase()];
        if (response != null) {
          // Add response after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _messages.add(
                Message(
                  text: response,
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
            _scrollToBottom();
          });
        }
      }
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  widget.user.isGroup ? Colors.green : Colors.deepPurple,
              child: Text(
                widget.user.avatarText ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.user.name),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
