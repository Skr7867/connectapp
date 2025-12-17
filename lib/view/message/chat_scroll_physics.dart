import 'package:flutter/material.dart';

class ChatScrollPhysics extends ScrollPhysics {
  const ChatScrollPhysics({super.parent});

  @override
  ChatScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Allow smooth scrolling
    return offset;
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
