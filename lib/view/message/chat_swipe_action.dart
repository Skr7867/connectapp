import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatSwipeAction extends StatelessWidget {
  final Widget child;
  final VoidCallback onLeftSwipeAction;
  final VoidCallback onRightSwipeAction;

  const ChatSwipeAction({
    required this.child,
    required this.onLeftSwipeAction,
    required this.onRightSwipeAction,
    super.key,
  });

  Widget buildAction(IconData icon, Color bgColor, VoidCallback onPressed) {
    return CustomSlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: bgColor,
      child: Center(
        child: Icon(
          icon,
          size: 36, // Larger icon size here
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          buildAction(Icons.notifications_off, const Color(0xFFFEC107), onLeftSwipeAction), // Orange - Mute
          buildAction(Icons.delete, const Color(0xFFF44336), onLeftSwipeAction),           // Red - Delete
          buildAction(Icons.archive, const Color(0xFFBDBDBD), onLeftSwipeAction),          // Grey - Archive
        ],
      ),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          buildAction(Icons.chat_bubble, const Color(0xFF2196F3), onRightSwipeAction),   // Blue - Chat
          buildAction(Icons.check, const Color(0xFF43A047), onRightSwipeAction),          // Green - Done
        ],
      ),
      child: child,
    );
  }
}
