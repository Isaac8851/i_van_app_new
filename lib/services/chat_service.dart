import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get messages stream
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => MessageModel.fromMap(doc.data())).toList(),
        );
  }

  // Send a message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  // Get unread messages count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: _auth.currentUser!.uid)
        .where('senderId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Helper method to generate consistent chat ID
  String _getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  Future<String?> uploadImage(String chatId, String filePath) async {
    // TODO: Implement image upload to Firebase Storage and return URL
    // For now, return a fake URL
    await Future.delayed(const Duration(seconds: 1));
    return 'https://fakeimg.pl/250x100/';
  }
}
