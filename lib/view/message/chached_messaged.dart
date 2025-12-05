import 'package:connectapp/view/message/fake.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CachedMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String senderId;

  @HiveField(5)
  final String senderName;

  @HiveField(6)
  final String? senderAvatar;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final String? messageType;

  @HiveField(9)
  final Map<String, dynamic>? replyTo;

  @HiveField(10)
  final Map<String, dynamic>? fileInfo;

  CachedMessage({
    required this.id,
    required this.chatId,
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.isRead,
    this.messageType,
    this.replyTo,
    this.fileInfo,
  });

  factory CachedMessage.fromMessage(Message message, String chatId) {
    return CachedMessage(
      id: message.id,
      chatId: chatId,
      content: message.content,
      timestamp: message.timestamp,
      senderId: message.sender.id,
      senderName: message.sender.name,
      senderAvatar: message.sender.avatar,
      isRead: message.isRead,
      messageType: message.messageType,
      replyTo: message.replyTo != null
          ? {
              'id': message.replyTo!.id,
              'content': message.replyTo!.content,
              'senderId': message.replyTo!.sender?.id,
              'senderName': message.replyTo!.sender?.name,
            }
          : null,
      fileInfo: message.fileInfo != null
          ? {
              'name': message.fileInfo!.name,
              'type': message.fileInfo!.type,
              'size': message.fileInfo!.size,
              'url': message.fileInfo!.url,
            }
          : null,
    );
  }

  Message toMessage() {
    return Message(
      id: id,
      content: content,
      timestamp: timestamp,
      sender: Sender(
        id: senderId,
        name: senderName,
        avatar: senderAvatar,
      ),
      isRead: isRead,
      messageType: messageType,
      replyTo: replyTo != null
          ? ReplyTo(
              id: replyTo!['id'],
              content: replyTo!['content'],
              sender: Sender(
                id: replyTo!['senderId'] ?? '',
                name: replyTo!['senderName'] ?? '',
                avatar: null,
              ),
            )
          : null,
      fileInfo: fileInfo != null
          ? FileInfo(
              name: fileInfo!['name'],
              type: fileInfo!['type'],
              size: fileInfo!['size'],
              url: fileInfo!['url'],
            )
          : null,
    );
  }
}
