// // Add these imports at the top of your file
// import 'package:flutter/services.dart';
// import 'package:flutter/gestures.dart';

// // Add these formatting state variables to your class
// class YourChatScreenState extends State<YourChatScreen> {
//   TextEditingController _messageController = TextEditingController();
//   bool _isBold = false;
//   bool _isItalic = false;
//   bool _isUnderline = false;

//   // ... your existing state variables

//   // UPDATED: Your existing _sendMessage method with formatting integration
//   void _sendMessage() {
//     if (selectedChatId == null ||
//         _messageController.text.trim().isEmpty ||
//         currentUserId == null) return;

//     final chat = selectedChat;
//     final isGroup = chat?.isGroup ?? false;
//     String? receiverId;

//     if (isGroup) {
//       receiverId = null;
//     } else {
//       if (pendingPrivateChatUserId != null) {
//         receiverId = pendingPrivateChatUserId;
//       } else {
//         final otherParticipant = chat?.participants?.firstWhere(
//           (p) => p.id != currentUserId,
//           orElse: () => null as Participant,
//         );
//         receiverId = otherParticipant?.id;
//       }
//     }

//     // UPDATED: Apply formatting to message content
//     String messageContent = _messageController.text.trim();
//     String formattedContent = _applyFormatting(messageContent);

//     final tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

//     // Optimistic UI update
//     final newMessage = Message(
//       id: tempMessageId,
//       content: formattedContent, // Use formatted content
//       timestamp: DateTime.now(),
//       sender: Sender(
//         id: currentUserId!,
//         name: currentUserName ?? 'You',
//         avatar: currentUserAvatar,
//       ),
//       isRead: false,
//       replyTo: replyingToMessage != null
//           ? ReplyTo(
//               id: replyingToMessage!.id,
//               content: replyingToMessage!.content,
//               sender: replyingToMessage!.sender,
//             )
//           : null,
//     );

//     setState(() {
//       messages[selectedChatId!] = [
//         ...(messages[selectedChatId!] ?? []),
//         newMessage
//       ];
//     });

//     _messageController.clear();

//     // UPDATED: Clear formatting state after sending
//     setState(() {
//       _isBold = false;
//       _isItalic = false;
//       _isUnderline = false;
//     });

//     _scrollToBottom();

//     _socketService.sendMessage(
//       senderId: currentUserId!,
//       receiverId: isGroup ? null : receiverId,
//       groupId: isGroup ? selectedChatId : null,
//       content: formattedContent, // Send formatted content
//       replyToMessageId: replyingToMessage?.id,
//       callback: (response) {
//         if (response['success'] == true && response['messageId'] != null) {
//           // Replace temporary ID with real ID
//           setState(() {
//             final chatMessages = messages[selectedChatId!] ?? [];
//             final updatedMessages = chatMessages
//                 .map((msg) => msg.id == tempMessageId
//                     ? Message(
//                         id: response['messageId']!,
//                         content: msg.content,
//                         timestamp: msg.timestamp,
//                         sender: msg.sender,
//                         isRead: msg.isRead,
//                         replyTo: msg.replyTo,
//                         reactions: msg.reactions,
//                       )
//                     : msg)
//                 .toList();
//             messages[selectedChatId!] = updatedMessages;
//           });
//         } else {
//           // Remove temporary message on failure
//           setState(() {
//             final chatMessages = messages[selectedChatId!] ?? [];
//             messages[selectedChatId!] =
//                 chatMessages.where((msg) => msg.id != tempMessageId).toList();
//           });
//           _showSnackBar('Failed to send message');
//         }
//       },
//     );
//   }

//   // NEW: Apply formatting markers to the message
//   String _applyFormatting(String text) {
//     String formattedText = text;

//     if (_isBold) {
//       formattedText = '*$formattedText*';
//     }
//     if (_isItalic) {
//       formattedText = '_${formattedText}_';
//     }
//     if (_isUnderline) {
//       formattedText = '~$formattedText~';
//     }

//     return formattedText;
//   }

//   // UPDATED: Your existing _buildMessageContent method with formatting support
//   Widget _buildMessageContent(String content) {
//     // Parse formatted text first, then handle URLs
//     return _buildFormattedContentWithUrls(content);
//   }

//   // NEW: Build formatted content that also handles URLs
//   Widget _buildFormattedContentWithUrls(String content) {
//     // First, parse the formatting and create text spans
//     List<TextSpan> formattedSpans = _parseFormattedText(content);

//     // Then, process each span to handle URLs
//     List<TextSpan> finalSpans = [];

//     for (TextSpan span in formattedSpans) {
//       if (span.text != null && _containsUrl(span.text!)) {
//         // This span contains URLs, split it further
//         finalSpans.addAll(_processUrlsInTextSpan(span));
//       } else {
//         // No URLs, keep the span as is
//         finalSpans.add(span);
//       }
//     }

//     return RichText(
//       text: TextSpan(
//         children: finalSpans,
//         style: const TextStyle(color: Colors.black),
//       ),
//     );
//   }

//   // NEW: Parse formatted text into TextSpans
//   List<TextSpan> _parseFormattedText(String text) {
//     // Check for simple formatting (single format per message)
//     if (_hasSimpleFormatting(text)) {
//       return [_parseSimpleFormatting(text)];
//     }

//     // For complex formatting, parse multiple formats
//     return _parseComplexFormatting(text);
//   }

//   // NEW: Check if text has simple formatting (wrapped in single format)
//   bool _hasSimpleFormatting(String text) {
//     return (text.length > 2 && text.startsWith('*') && text.endsWith('*')) ||
//         (text.length > 2 && text.startsWith('_') && text.endsWith('_')) ||
//         (text.length > 2 && text.startsWith('~') && text.endsWith('~'));
//   }

//   // NEW: Parse simple formatting (single format)
//   TextSpan _parseSimpleFormatting(String text) {
//     String displayText = text;
//     TextStyle style = const TextStyle(fontSize: 16);

//     if (text.length > 2 && text.startsWith('*') && text.endsWith('*')) {
//       // Bold
//       displayText = text.substring(1, text.length - 1);
//       style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
//     } else if (text.length > 2 && text.startsWith('_') && text.endsWith('_')) {
//       // Italic
//       displayText = text.substring(1, text.length - 1);
//       style = const TextStyle(fontSize: 16, fontStyle: FontStyle.italic);
//     } else if (text.length > 2 && text.startsWith('~') && text.endsWith('~')) {
//       // Underline
//       displayText = text.substring(1, text.length - 1);
//       style =
//           const TextStyle(fontSize: 16, decoration: TextDecoration.underline);
//     }

//     return TextSpan(text: displayText, style: style);
//   }

//   // NEW: Parse complex formatting (multiple formats in one message)
//   List<TextSpan> _parseComplexFormatting(String text) {
//     List<TextSpan> spans = [];
//     int currentIndex = 0;

//     while (currentIndex < text.length) {
//       // Find the next formatting marker
//       int nextMarkerIndex = text.length;
//       String nextMarker = '';

//       // Look for formatting markers
//       for (String marker in ['*', '_', '~']) {
//         int index = text.indexOf(marker, currentIndex);
//         if (index != -1 && index < nextMarkerIndex) {
//           nextMarkerIndex = index;
//           nextMarker = marker;
//         }
//       }

//       // Add plain text before the marker (if any)
//       if (nextMarkerIndex > currentIndex) {
//         spans.add(TextSpan(
//           text: text.substring(currentIndex, nextMarkerIndex),
//           style: const TextStyle(fontSize: 16),
//         ));
//       }

//       // If no more markers found, we're done
//       if (nextMarkerIndex >= text.length || nextMarker.isEmpty) {
//         break;
//       }

//       // Find the closing marker
//       int closingIndex = text.indexOf(nextMarker, nextMarkerIndex + 1);

//       if (closingIndex != -1) {
//         // Extract the content between markers
//         String content = text.substring(nextMarkerIndex + 1, closingIndex);

//         // Apply formatting based on marker type
//         TextStyle style = _getStyleForMarker(nextMarker);
//         spans.add(TextSpan(
//           text: content,
//           style: style,
//         ));

//         // Move past the closing marker
//         currentIndex = closingIndex + 1;
//       } else {
//         // No closing marker found, treat as plain text
//         spans.add(TextSpan(
//           text: text.substring(nextMarkerIndex),
//           style: const TextStyle(fontSize: 16),
//         ));
//         break;
//       }
//     }

//     return spans.isEmpty
//         ? [TextSpan(text: text, style: const TextStyle(fontSize: 16))]
//         : spans;
//   }

//   // NEW: Get TextStyle for formatting markers
//   TextStyle _getStyleForMarker(String marker) {
//     switch (marker) {
//       case '*':
//         return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
//       case '_':
//         return const TextStyle(fontSize: 16, fontStyle: FontStyle.italic);
//       case '~':
//         return const TextStyle(
//             fontSize: 16, decoration: TextDecoration.underline);
//       default:
//         return const TextStyle(fontSize: 16);
//     }
//   }

//   // NEW: Process URLs within a TextSpan
//   List<TextSpan> _processUrlsInTextSpan(TextSpan originalSpan) {
//     final String text = originalSpan.text ?? '';
//     final TextStyle baseStyle =
//         originalSpan.style ?? const TextStyle(fontSize: 16);

//     final urlRegex = RegExp(r'https?://[^\s]+');
//     final matches = urlRegex.allMatches(text);

//     if (matches.isEmpty) {
//       return [originalSpan];
//     }

//     List<TextSpan> spans = [];
//     int lastEnd = 0;

//     for (final match in matches) {
//       // Add text before URL
//       if (match.start > lastEnd) {
//         spans.add(TextSpan(
//           text: text.substring(lastEnd, match.start),
//           style: baseStyle,
//         ));
//       }

//       // Add clickable URL
//       final url = match.group(0)!;
//       spans.add(TextSpan(
//         text: url,
//         style: baseStyle.copyWith(
//           color: Colors.blue,
//           decoration: TextDecoration.underline,
//         ),
//         recognizer: TapGestureRecognizer()..onTap = () => _openUrl(url),
//       ));

//       lastEnd = match.end;
//     }

//     // Add remaining text
//     if (lastEnd < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(lastEnd),
//         style: baseStyle,
//       ));
//     }

//     return spans;
//   }

//   // Your existing _containsUrl method (keep as is)
//   bool _containsUrl(String text) {
//     final urlRegex = RegExp(r'https?://[^\s]+');
//     return urlRegex.hasMatch(text);
//   }

//   // Your existing _openUrl method (keep as is)
//   Future<void> _openUrl(String url) async {
//     try {
//       print('Opening URL: $url');
//       final Uri uri = Uri.parse(url);
//       bool launched = false;

//       // Strategy 1: Try external application
//       try {
//         if (await canLaunchUrl(uri)) {
//           launched = await launchUrl(
//             uri,
//             mode: LaunchMode.externalApplication,
//           );
//         }
//       } catch (e) {
//         print('External app URL launch failed: $e');
//       }

//       // Strategy 2: Try platform default
//       if (!launched) {
//         try {
//           launched = await launchUrl(
//             uri,
//             mode: LaunchMode.platformDefault,
//           );
//         } catch (e) {
//           print('Platform default URL launch failed: $e');
//         }
//       }

//       // Strategy 3: Try in-app web view
//       if (!launched) {
//         try {
//           launched = await launchUrl(
//             uri,
//             mode: LaunchMode.inAppWebView,
//             webViewConfiguration: const WebViewConfiguration(
//               enableJavaScript: true,
//               enableDomStorage: true,
//             ),
//           );
//         } catch (e) {
//           print('In-app web view URL launch failed: $e');
//         }
//       }

//       if (!launched) {
//         _showSnackBar(
//             'Cannot open URL. Please check your internet connection.');
//       }
//     } catch (e) {
//       print('Error opening URL: $e');
//       _showSnackBar('Invalid URL format');
//     }
//   }

//   // NEW: Build the message input area with formatting toolbar
//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey[300]!)),
//       ),
//       child: Column(
//         children: [
//           // Formatting toolbar
//           _buildFormattingToolbar(),
//           const SizedBox(height: 8),

//           // Message input row
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(25),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: TextField(
//                           controller: _messageController,
//                           decoration: const InputDecoration(
//                             hintText: 'Type a message...',
//                             border: InputBorder.none,
//                           ),
//                           maxLines: null,
//                           textInputAction: TextInputAction.newline,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.attach_file, color: Colors.grey),
//                         onPressed: () {
//                           // Handle file attachment
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               FloatingActionButton(
//                 mini: true,
//                 onPressed: _sendMessage,
//                 backgroundColor: Colors.blue,
//                 child: const Icon(Icons.send, color: Colors.white),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // NEW: Formatting toolbar widget
//   Widget _buildFormattingToolbar() {
//     return Container(
//       height: 40,
//       child: Row(
//         children: [
//           Text(
//             'Format: ',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(width: 8),

//           // Bold button
//           _buildFormatButton(
//             icon: Icons.format_bold,
//             isActive: _isBold,
//             onPressed: () => setState(() => _isBold = !_isBold),
//             tooltip: 'Bold',
//           ),

//           // Italic button
//           _buildFormatButton(
//             icon: Icons.format_italic,
//             isActive: _isItalic,
//             onPressed: () => setState(() => _isItalic = !_isItalic),
//             tooltip: 'Italic',
//           ),

//           // Underline button
//           _buildFormatButton(
//             icon: Icons.format_underline,
//             isActive: _isUnderline,
//             onPressed: () => setState(() => _isUnderline = !_isUnderline),
//             tooltip: 'Underline',
//           ),

//           const SizedBox(width: 16),

//           // Clear formatting button
//           InkWell(
//             onTap: () {
//               setState(() {
//                 _isBold = false;
//                 _isItalic = false;
//                 _isUnderline = false;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 'Clear',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // NEW: Helper method to build format buttons
//   Widget _buildFormatButton({
//     required IconData icon,
//     required bool isActive,
//     required VoidCallback onPressed,
//     required String tooltip,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(4),
//         child: Container(
//           width: 32,
//           height: 32,
//           margin: const EdgeInsets.only(right: 4),
//           decoration: BoxDecoration(
//             color: isActive ? Colors.blue[100] : Colors.transparent,
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(
//               color: isActive ? Colors.blue : Colors.grey[300]!,
//             ),
//           ),
//           child: Icon(
//             icon,
//             size: 18,
//             color: isActive ? Colors.blue : Colors.grey[600],
//           ),
//         ),
//       ),
//     );
//   }
// }
