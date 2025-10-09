import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp;

  MessageModel({
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    return MessageModel(
      senderId: data['senderId'] as String,
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    if (text != null) 'text': text,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'timestamp': timestamp,
  };
}
