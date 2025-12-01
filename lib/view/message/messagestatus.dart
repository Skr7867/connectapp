import 'package:flutter/material.dart';
class MessageStatusWidget extends StatelessWidget {
  final String status;
  final bool isMyMessage;
  final Color? color;
 const MessageStatusWidget({
    super.key,
    required this.status,
    required this.isMyMessage,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMyMessage) return const SizedBox.shrink();

    Color tickColor = color ?? Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'sent':
        return Icon(
          Icons.check,
          size: 16,
          color: tickColor,
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 16,
          color: tickColor,
        );
      case 'read':
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue, // Blue color for read messages
        );
      default:
        return Icon(
          Icons.schedule,
          size: 16,
          color: tickColor,
        );
    }
  }
}