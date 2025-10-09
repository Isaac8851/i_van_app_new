class User {
  final String id;
  final String name;
  final String? avatarText;
  final bool isGroup;
  final String? lastMessage;

  User({
    required this.id,
    required this.name,
    this.avatarText,
    this.isGroup = false,
    this.lastMessage,
  });
}
