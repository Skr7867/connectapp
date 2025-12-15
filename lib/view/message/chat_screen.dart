import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectapp/data/response/status.dart';
import 'package:connectapp/models/EnrolledCourses/enrolled_courses_model.dart';
import 'package:connectapp/models/UserLogin/user_login_model.dart';
import 'package:connectapp/models/UserProfile/user_profile_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/utils/file_utils.dart';
import 'package:connectapp/view/message/audiorecord.dart';
import 'package:connectapp/view/message/chat_background_painter.dart';
import 'package:connectapp/view/message/community.dart';
import 'package:connectapp/view/message/editgroupinfo.dart';
import 'package:connectapp/view/message/groupmanagement.dart';
import 'package:connectapp/view/message/stickerprofile.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/GroupUnreadCount/group_unread_count_model.dart';
import '../../models/UnreadCount/unread_count_model.dart';
import '../../res/assets/image_assets.dart';
import '../../res/routes/routes_name.dart';
import '../../utils/cache_image_loader.dart';
import '../../utils/local_file_manager.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/chatDelete/chat_delete_controller.dart';
import '../../view_models/controller/groupUnreadCount/group_unread_count_controller.dart';
import '../../view_models/controller/service/chatservice.dart';
import '../../view_models/controller/service/service.dart';
import '../../view_models/controller/service/socketservice.dart';
import '../../view_models/controller/unreadCount/unread_count_controller.dart';
import 'chat_open_tracker.dart';
import 'chat_profile.dart';
import 'notificationservice.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? directUserId;
  const ChatScreen({super.key, this.chatId, this.directUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, String> _translatedMessages = {}; // Store translations
  final Set<String> _translatingMessages = {};
  bool _autoTranslate = false;
  String? _translationError;
  final Set<String> _recentlySentMessages = {};
  final SocketService _socketService = SocketService();
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, List<dynamic>> chatMessages = {};
  bool _isLoadingMessages = false;
  bool isGroup = false;
  Map<String, String?> lastReadMessageId = {};
  bool _hasShownUnreadSeparator = false;
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  String? selectedChatId;
  StreamSubscription<Map<String, dynamic>>? _unreadCountSubscription;
  // Map<String, int> unreadCounts = {};
  bool _isBold = false;
  final Map<String, GlobalKey> _messageKeys = {};
  bool _isItalic = false;
  final UserProfileController _profileController =
      Get.put(UserProfileController());
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();
  UserProfileModel? currentUserProfile;
  bool _isUnderline = false;
  bool showReplyPreview = false;
  String? _highlightedMessageId;
  bool _isEditingMode = false;
  final TextEditingController _editMessageController = TextEditingController();
  Message? _editingMessage;
  bool _showScrollToBottom = false;
  static const double _scrollThreshold = 50.0;
  static const double _bottomThreshold = 100.0;
  Timer? _highlightTimer;
  String selectedSection = 'all'; // 'all', 'direct', 'groups'
  List<GroupData> groups = [];
  List<Chat> directChats = [];
  LocalFileManager localFileManager = LocalFileManager();
  Map<String, List<dynamic>> pinnedMessagesByChat = {};
  late StreamSubscription _errorSubscription;

  List<GroupData> filteredGroups = [];
  String? _selectedReportReason;
  bool _showForwardDialog = false;
  Message? _messageToForward;
  final List<String> _selectedForwardChats = [];

  final LocalFileManager _localFileManager = LocalFileManager();
  String _forwardSearchQuery = '';
  final TextEditingController _forwardSearchController =
      TextEditingController();
  Map<String, List<dynamic>> chatPinnedMessages = {};
  String _reportDescription = '';
  final TextEditingController _reportDescriptionController =
      TextEditingController();
  List<Chat> filteredDirectChats = [];
  Map<String, List<Message>> messages = {};
  String otherId = "";
  Set<String> joinedGroups = {};
  String? inviteLink;
  bool isGeneratingLink = false;
  bool loading = true;
  String? error;
  bool showEmojiPicker = false;
  bool showCommunityMembers = false;
  String? openMenuMemberId;
  String? activePrivateChat;
  String? pendingPrivateChatUserId;
  bool isNewPrivateChat = false;
  bool showChatList = true;
  bool showForwardModal = false; // Add this for forward modal
  String? forwardMessageId;
  List<ForwardTarget> availableForwardTargets = [];
  StreamSubscription<Map<String, dynamic>>? _newMessageSubscription;
  bool showGroupInfo = false;
  String? currentUserId;
  String? currentUserName;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isUserAtBottom = true;
  String? currentUserAvatar;
  late AnimationController _animationController;
  bool _isLoadingOlderMessages = false;
  final Map<String, bool> _hasMoreMessages = {};
  // final Map<String, String?> _oldestMessageId = {};
  late Animation<double> _fadeAnimation;
  Message? replyingToMessage;
  StreamSubscription<Map<String, dynamic>>? _groupDeletedSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _groupDetailsSubscription;

  // Add these StreamSubscriptions for lazy loading

  Color? appBackgroundColor = Colors.grey[300];

  StreamSubscription? _messageDeletedSubscription;
  StreamSubscription? _privateMessageSubscription;
  StreamSubscription? adminAddedSubscription;
  StreamSubscription<Map<String, dynamic>>? _messageReactionSubscription;
  late StreamSubscription _pinnedMessageSubscription;
  StreamSubscription? _messagesReadSubscription;
  bool _showMentionSheet = false;
  String _currentMentionQuery = '';
  List<GroupMember> _filteredMentions = [];
  int _mentionStartPosition = -1;
  final List<Map<String, dynamic>> _mentionsInMessage = [];
  // Add this method after _getInitials method (around line 800)
  List<GroupMember> _getGroupMembersForMention() {
    if (!isGroup || selectedChat == null) return [];

    final participants = selectedGroup!.members!;

    // Filter out current user
    return participants.where((p) => p.id != currentUserId).toList();
  }

  late StreamSubscription _unpinnedMessageSubscription;

  final List<String> emojiReactions = [
    "👍",
    "❤️",
    "😂",
    "😮",
    "😢",
    "👏",
    "🔥",
    "💯",
    "🤯",
    "😎",
    "🙌",
    "💀",
    "🤔",
    "😭",
    "🤷",
    "😇",
    "🤝",
    "⚡",
    "😍",
    "🤩",
    "😡",
    "🤬",
    "🥱",
    "😤",
    "😬",
    "🎉",
    "🥳",
    "🎂",
    "💤",
    "💪",
    "🥂",
    "😇",
    "😈",
    "🤡",
    "👀",
    "😴",
    "😷",
    "👎",
    "🌈",
    "😵",
    "🤓",
    "🤑",
    "😕",
    "🧠",
    "😐",
    "😌",
    "😳",
    "😔",
    "😅",
    "🎯",
    "📌",
    "😒",
    "🤗",
    "👊",
    "✌️",
    "🖤",
    "💔",
    "🌟",
    "💫",
    "🚀",
    "🥴"
  ];

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  List<Message> pinnedMessages = [];
  bool _isChatSearching = false;
  String _chatSearchQuery = '';
  final TextEditingController _chatSearchController = TextEditingController();
  List<Message> _chatFilteredMessages = [];

  DateTime parseTimestamp(dynamic ts) {
    if (ts == null) return DateTime.now();

    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);

    if (ts is String) {
      try {
        return DateTime.parse(ts);
      } catch (_) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  void _onMessageTextChanged(String text) {
    if (!isGroup) return;

    final cursorPosition = _messageController.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      final isValidMention = lastAtIndex == 0 ||
          text[lastAtIndex - 1] == ' ' ||
          text[lastAtIndex - 1] == '\n';

      if (isValidMention) {
        final query = textBeforeCursor.substring(lastAtIndex + 1);

        // ✅ FIX: Allow space ONLY if query is empty (just typed @)
        // Close mention if there's a space AND we have text before it
        if (query.contains(' ') && query.trim().isNotEmpty) {
          setState(() {
            _showMentionSheet = false;
            _currentMentionQuery = '';
            _filteredMentions = [];
          });
          return;
        }

        setState(() {
          _showMentionSheet = true;
          _mentionStartPosition = lastAtIndex;
          _currentMentionQuery = query.toLowerCase();
          _filteredMentions = _getGroupMembersForMention()
              .where((p) => p.userId.username!
                  .toLowerCase()
                  .contains(_currentMentionQuery))
              .toList();
        });
        return;
      }
    }

    setState(() {
      _showMentionSheet = false;
      _currentMentionQuery = '';
      _filteredMentions = [];
    });
  }

  void _selectMention(GroupMember participant) {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

    // Replace from @ to cursor with the mention
    final beforeMention = text.substring(0, _mentionStartPosition);
    final afterCursor = text.substring(cursorPosition);

    // ✅ Use participant.userId.fullName instead of participant.name
    final mentionText = '@${participant.userId.username}';
    final newText = '$beforeMention$mentionText $afterCursor';

    // Store mention info for later processing
    _mentionsInMessage.add({
      'userId': participant.userId.id,
      'userName': participant.userId.username,
      'startIndex': _mentionStartPosition,
      'endIndex': _mentionStartPosition + mentionText.length,
    });

    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: beforeMention.length + mentionText.length + 1),
    );

    setState(() {
      _showMentionSheet = false;
      _currentMentionQuery = '';
      _filteredMentions = [];
    });
  }

  List<Map<String, dynamic>> _extractMentionsFromText(String text) {
    final mentions = <Map<String, dynamic>>[];
    final groupMembers = _getGroupMembersForMention();

    // Find all @ symbols
    int index = 0;
    while (index < text.length) {
      final atIndex = text.indexOf('@', index);
      if (atIndex == -1) break;
      int endIndex = atIndex + 1;
      while (endIndex < text.length) {
        final char = text[endIndex];
        // Stop at space, newline, or common punctuation
        if (char == ' ' ||
            char == '\n' ||
            char == ',' ||
            char == '.' ||
            char == '!' ||
            char == '?') {
          break;
        }
        endIndex++;
      }

      final mentionText = text.substring(atIndex + 1, endIndex);

      // Try to match with a group member
      final participant = groupMembers.firstWhereOrNull(
        (p) =>
            p.userId.fullName == mentionText ||
            p.userId.username == mentionText.toLowerCase(),
      );

      if (participant != null) {
        mentions.add({
          'userId': participant.userId.id, // ✅ Use userId.id
          'userName': participant.userId.username, // ✅ Use userId.fullName
          'startIndex': atIndex,
          'endIndex': endIndex,
        });
      }

      index = endIndex;
    }

    return mentions;
  }

  // Add this widget method after _buildForwardPreviewContent (around line 1100)
  Widget _buildMentionSheet() {
    if (!_showMentionSheet || _filteredMentions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 120, // Position above the input field
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.greyColor.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alternate_email,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Mention someone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredMentions.length,
                  itemBuilder: (context, index) {
                    final participant = _filteredMentions[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        backgroundImage: participant.userId.avatar != null &&
                                participant.userId.avatar!.imageUrl.isNotEmpty
                            ? CacheImageLoader(
                                participant.userId.avatar!.imageUrl,
                                ImageAssets.defaultProfileImg,
                              )
                            : null,
                        child: participant.userId.avatar == null ||
                                participant.userId.avatar!.imageUrl.isEmpty
                            ? Text(
                                _getInitials(participant.userId.fullName),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        participant.userId.fullName.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        participant.userId.username.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () => _selectMention(participant),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Add this method to show forward dialog
  void _showForwardMessageDialog(Message message) {
    setState(() {
      _messageToForward = message;
      _showForwardDialog = true;
      _selectedForwardChats.clear();
      _forwardSearchQuery = '';
      _forwardSearchController.clear();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // ✅ Load older messages when scrolling near the top
    if (offset <= _scrollThreshold &&
        !_isLoadingOlderMessages &&
        selectedChatId != null &&
        (_hasMoreMessages[selectedChatId] ?? true)) {
      _loadOlderMessages();
    }

    // ✅ Update scroll to bottom button visibility
    // Show button if not at bottom (more than 100 pixels from bottom)
    final shouldShowButton = maxScroll - offset > 100;

    if (shouldShowButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = shouldShowButton;
      });
    }

    // ✅ Update user at bottom state
    final isAtBottom = maxScroll - offset < _bottomThreshold;
    if (isAtBottom != _isUserAtBottom) {
      setState(() {
        _isUserAtBottom = isAtBottom;
      });
    }
  }

  void _loadOlderMessages() {
    if (selectedChatId == null || _isLoadingOlderMessages) {
      return;
    }
    if (_hasMoreMessages[selectedChatId] == false) {
      return;
    }

    setState(() {
      _isLoadingOlderMessages = true;
    });
    Timer(Duration(seconds: 10), () {
      if (_isLoadingOlderMessages) {
        setState(() {
          _isLoadingOlderMessages = false;
        });
        _showSnackBar('Request timeout. Please try again.');
      }
    });

    final chat = selectedChat;
    if (chat == null) {
      setState(() {
        _isLoadingOlderMessages = false;
      });
      return;
    }

    final currentMessages = messages[selectedChatId] ?? [];
    final oldestMessageId =
        currentMessages.isNotEmpty ? currentMessages.first.id : null;

    if (chat.isGroup) {
      isGroup = true;
      _socketService.loadOlderGroupMessages(
        groupId: selectedChatId!,
        beforeMessageId: oldestMessageId,
        limit: 50,
        onResponse: _handleOlderGroupMessages,
      );
    } else {
      isGroup = false;
      final otherParticipant = chat.participants?.firstWhere(
        (p) => p.id != currentUserId,
      );

      if (otherParticipant != null && currentUserId != null) {
        _socketService.loadOlderPrivateMessages(
          user1Id: currentUserId!,
          user2Id: otherParticipant.id,
          beforeMessageId: oldestMessageId,
          limit: 50,
          onResponse: _handleOlderPrivateMessages,
        );
      } else {
        setState(() {
          _isLoadingOlderMessages = false;
        });
        _showSnackBar('Unable to load older messages');
      }
    }
  }

  void _clearReplyState() {
    setState(() {
      replyingToMessage = null;
      showReplyPreview = false;
      // Also clear editing state to be safe
      _isEditingMode = false;
      _editingMessage = null;
    });
  }

  Future<void> _translateMessage(Message message) async {
    // Don't translate own messages
    if (message.sender.id == currentUserId) {
      _showSnackBar('Cannot translate your own messages');
      return;
    }

    // Check if already translated
    if (_translatedMessages.containsKey(message.id)) {
      // Toggle translation off
      setState(() {
        _translatedMessages.remove(message.id);
      });
      return;
    }

    // Show loading state
    setState(() {
      _translatingMessages.add(message.id);
      _translationError = null;
    });

    try {
      final translatedText = await _chatService.translateText(message.content);

      if (translatedText != null && mounted) {
        setState(() {
          _translatedMessages[message.id] = translatedText;
          _translatingMessages.remove(message.id);
        });
        _showSuccessSnackBar('Message translated successfully');
      } else {
        throw Exception('Translation returned null');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _translatingMessages.remove(message.id);
          _translationError = error.toString();
        });

        // Show appropriate error message
        String errorMessage = 'Translation failed';
        if (error.toString().contains('Premium')) {
          errorMessage = 'Translation requires Premium+ subscription';
        }
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  void _forwardMessage() {
    if (_messageToForward == null || _selectedForwardChats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one chat to forward to'),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final targets = _selectedForwardChats.map((chatId) {
      final chat = allChats.firstWhere((c) => c.id == chatId);
      return {
        'type': chat.isGroup ? 'group' : 'user',
        'id': chatId,
      };
    }).toList();

    bool isDialogOpen = true;

    _socketService.forwardMessage(
      originalMessageId: _messageToForward!.id,
      senderId: currentUserId!,
      targets: targets,
      callback: (success, message) {
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }

        if (!mounted) return;

        if (success) {
          _fetchPrivateChats();
          _fetchGroups();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _sortChatsSafely();
          });

          Utils.toastMessageCenter('Forwarded');
          // Close forward dialog properly
          setState(() {
            _showForwardDialog = false;
            _messageToForward = null;
            _selectedForwardChats.clear();
            _forwardSearchQuery = '';
            _forwardSearchController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message ?? 'Failed to forward message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    // ✅ Safety timeout to close dialog if callback never fires
    Timer(const Duration(seconds: 10), () {
      if (isDialogOpen && mounted) {
        Navigator.of(context).pop();
        isDialogOpen = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forward operation timed out'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  // Enhanced scroll listener
  void _initScrollListener() {
    _scrollController.addListener(() {
      final position = _scrollController.position;
      final isAtBottom =
          position.pixels >= position.maxScrollExtent - _bottomThreshold;

      // Update user position state
      if (isAtBottom != _isUserAtBottom) {
        setState(() {
          _isUserAtBottom = isAtBottom;
        });
      }

      // Show/hide scroll to bottom button
      final shouldShowButton = !isAtBottom &&
          position.pixels < position.maxScrollExtent - _scrollThreshold;

      if (shouldShowButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = shouldShowButton;
        });
      }
    });
  }

// Add this method to get available emojis based on subscription
  List<String> _getAvailableEmojis() {
    // Get the number of allowed emojis from subscription features
    final allowedEmojis =
        currentUserProfile?.subscriptionFeatures?.reactionEmoji ?? 4;

    // Return emojis based on subscription level
    if (allowedEmojis >= emojiReactions.length) {
      return emojiReactions;
    } else {
      return emojiReactions.take(allowedEmojis).toList();
    }
  }

  Future<bool> _validateFileSize(File file) async {
    try {
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // Get the file upload size limit from user profile (in MB)
      final fileUploadSizeLimit =
          currentUserProfile?.subscriptionFeatures?.fileUploadSize ??
              10; // Default 10MB if not found

      if (fileSizeInMB > fileUploadSizeLimit) {
        // Show warning dialog
        await _showFileSizeWarningDialog(fileSizeInMB, fileUploadSizeLimit);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

// Dialog to show file size warning
  Future<void> _showFileSizeWarningDialog(
      double actualSize, int maxSize) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'File Size Limit Exceeded',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The selected file is too large to upload.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                        'Current file size: ${actualSize.toStringAsFixed(2)} MB'),
                    Text('Maximum allowed: $maxSize MB'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                maxSize < 100
                    ? 'Upgrade to premium for larger file uploads!'
                    : 'Please select a smaller file.',
                style: TextStyle(
                  color: maxSize < 100 ? Colors.blue : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (maxSize < 100) // Show upgrade button for non-premium users
              TextButton(
                child: Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular),
                ),
                onPressed: () {
                  Get.toNamed(RouteName.membershipPlan);
                },
              ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Add this method to build forward dialog
  Widget _buildForwardDialog() {
    if (!_showForwardDialog || _messageToForward == null) {
      return const SizedBox();
    }

    final filteredChats = _forwardSearchQuery.isEmpty
        ? allChats.where((chat) => chat.id != selectedChatId).toList()
        : allChats.where((chat) {
            final nameMatch =
                chat.name.toLowerCase().contains(_forwardSearchQuery);
            final participantMatch = chat.participants?.any((p) =>
                    p.name.toLowerCase().contains(_forwardSearchQuery)) ??
                false;
            return (nameMatch || participantMatch) && chat.id != selectedChatId;
          }).toList();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.greyColor, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: () =>
                          setState(() => _showForwardDialog = false),
                    ),
                    Text(
                      'Forward Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedForwardChats.isNotEmpty)
                      TextButton(
                        onPressed: _forwardMessage,
                        child: Text(
                          'Send (${_selectedForwardChats.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Message Preview
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.forward,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _messageToForward!.sender.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              fontFamily: AppFonts.opensansRegular,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildForwardPreviewContent(_messageToForward!)
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _forwardSearchController,
                  onChanged: (value) =>
                      setState(() => _forwardSearchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chat List
              Expanded(
                child: filteredChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No chats found',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppFonts.opensansRegular,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          final isSelected =
                              _selectedForwardChats.contains(chat.id);

                          return ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: CacheImageLoader(
                                      chat.avatar,
                                      ImageAssets.defaultProfileImg,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text(
                              chat.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.opensansRegular,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            subtitle: chat.isGroup
                                ? Text(
                                    '${chat.participants?.length ?? 0} members',
                                    style: TextStyle(
                                      fontFamily: AppFonts.opensansRegular,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  )
                                : null,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                if (_selectedForwardChats.contains(chat.id)) {
                                  _selectedForwardChats.remove(chat.id);
                                } else {
                                  _selectedForwardChats.add(chat.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForwardPreviewContent(Message msg) {
    final type = msg.messageType?.toLowerCase() ?? "text";
    final content = msg.content;

    switch (type) {
      case "text":
        return Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.opensansRegular,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        );

      case "images":
      case "sticker":
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            content,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
        );

      case "video":
        return Container(
          height: 50,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Icon(Icons.play_circle, size: 28, color: Colors.white),
          ),
        );

      case "audio":
        return Row(
          children: [
            Icon(Icons.audiotrack, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              "Audio message",
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        );

      case "file":
        return Row(
          children: [
            Icon(Icons.insert_drive_file, size: 22, color: Colors.black),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "File",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        );

      default:
        return Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  void _sendStickerMessage(String stickerUrl) {
    if (selectedChatId == null || currentUserId == null) return;

    final chat = selectedChat;
    final isGroup = chat?.isGroup ?? false;
    String? receiverId;

    if (isGroup) {
      receiverId = null;
    } else {
      if (pendingPrivateChatUserId != null) {
        receiverId = pendingPrivateChatUserId;
      } else {
        final otherParticipant = chat?.participants?.firstWhere(
          (p) => p.id != currentUserId,
          orElse: () => null as Participant,
        );
        receiverId = otherParticipant?.id;
      }
    }

    final tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    // Store reply information BEFORE clearing state
    final isReplying = showReplyPreview && replyingToMessage != null;
    final replyToMessageId = replyingToMessage?.id;

    // Create new sticker message
    final newMessage = Message(
      id: tempMessageId,
      content: stickerUrl,
      timestamp: DateTime.now(),
      sender: Sender(
        id: currentUserId!,
        name: currentUserName ?? 'Me',
        avatar: currentUserAvatar,
      ),
      isRead: false,
      messageType: 'sticker',
      replyTo: isReplying
          ? ReplyTo(
              id: replyingToMessage!.id,
              content: replyingToMessage!.content,
              sender: replyingToMessage!.sender,
            )
          : null,
    );

    // Optimistic UI update
    setState(() {
      messages[selectedChatId!] = [
        ...(messages[selectedChatId!] ?? []),
        newMessage
      ];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    _cancelReply();
    _socketService.sendMessage(
      senderId: currentUserId!,
      receiverId: isGroup ? null : receiverId,
      groupId: isGroup ? selectedChatId : null,
      content: stickerUrl,
      mentions: [],
      messageType: 'sticker',
      replyToMessageId:
          isReplying ? replyToMessageId : null, // Use stored value
      callback: (response) {
        if (response['success'] == true && response['messageId'] != null) {
          // Replace temporary ID with real ID
          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            final updatedMessages = chatMessages
                .map((msg) => msg.id == tempMessageId
                    ? Message(
                        id: response['messageId']!,
                        content: msg.content,
                        timestamp: msg.timestamp,
                        sender: msg.sender,
                        isRead: msg.isRead,
                        messageType: msg.messageType,
                        replyTo: msg.replyTo,
                        reactions: msg.reactions,
                      )
                    : msg)
                .toList();
            messages[selectedChatId!] = updatedMessages;
          });
        } else {
          // Remove temporary message on failure
          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            messages[selectedChatId!] =
                chatMessages.where((msg) => msg.id != tempMessageId).toList();
          });
          _showSnackBar('Failed to send sticker');
        }
      },
    );
  }

  // 3. Update the _showStickerSelector function
  void _showStickerSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StickerSelectorWidget(
        onStickerSelected: (stickerUrl) {
          // Send the selected sticker
          _sendStickerMessage(stickerUrl);
          Navigator.pop(context);
        },
        userProfile: currentUserProfile,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  Future<void> _starMessage(dynamic message) async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;
    try {
      // Get the message ID
      String? messageId = _getMessageId(message);

      if (messageId == null) {
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not identify message'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Replace with your actual API endpoint
      final String apiUrl =
          '${ApiUrls.baseUrl}/connect/v1/api/chat/toggle-starred-message'; // Update this URL

      // Make the POST request
      final response = await http.post(
        Uri.parse('$apiUrl/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Success - show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  responseData['message'] ?? 'Message starred successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // API returned success: false
          throw Exception(responseData['message'] ?? 'Unknown error occurred');
        }
      } else {
        // HTTP error
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to star message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<dynamic>> _fetchStarredMessages() async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;
    try {
      // Replace with your actual API endpoint
      final String apiUrl =
          '${ApiUrls.baseUrl}/connect/v1/api/chat/get-starred-messages'; // Update this URL

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return responseData['messages'] ?? [];
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch starred messages');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _removeStarFromMessage(String messageId) async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;
    try {
      // Replace with your actual API endpoint for removing star
      final String apiUrl =
          '${ApiUrls.baseUrl}/connect/v1/api/chat/toggle-starred-message'; // Update this URL

      final response = await http.post(
        // or POST, depending on your API
        Uri.parse('$apiUrl/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

// Method to format date
  String _formatDates(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        return 'Unknown date';
      }
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      return dateString ?? 'Unknown date';
    }
  }

// Method to show starred messages popup
  void _showStarredMessagesPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Starred Messages',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),

                // Content
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _fetchStarredMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showStarredMessagesPopup(context);
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No starred messages',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final sender = message['sender'] ?? {};
                          final senderName =
                              sender['fullName']?.toString() ?? 'Unknown';
                          final content = message['content']?.toString() ?? '';
                          final createdAt =
                              message['createdAt']?.toString() ?? '';
                          final messageId = message['_id']?.toString() ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sender and date row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          senderName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDates(createdAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Message content
                                  Text(
                                    content,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),

                                  // Remove star button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        // Show loading indicator
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        // Remove star
                                        final success =
                                            await _removeStarFromMessage(
                                                messageId);

                                        // Close loading indicator
                                        Navigator.pop(context);

                                        if (success) {
                                          // Show success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Star removed successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          // Refresh the popup
                                          Navigator.pop(context);
                                          _showStarredMessagesPopup(context);
                                        } else {
                                          // Show error message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Failed to remove star'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Remove Star',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//link generator code
  Future<void> _generateInviteLink() async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;
    if (selectedGroup == null) return;

    setState(() {
      isGeneratingLink = true;
    });

    try {
      final response = await http.patch(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/user/generate-group-invite-link/${selectedGroup!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add your auth token here
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          inviteLink = data['inviteLink'];

          isGeneratingLink = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(data['message'] ?? 'Invite link generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to generate invite link');
      }
    } catch (e) {
      setState(() {
        isGeneratingLink = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate invite link. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Method to copy link to clipboard
  Future<void> _copyInviteLink() async {
    if (inviteLink != null) {
      await Clipboard.setData(ClipboardData(text: inviteLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Method to show invite link dialog
  void _showInviteLinkDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Group Invite Link',
            style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share this link to invite others to the group:',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  inviteLink ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _copyInviteLink();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.copy, size: 18, color: Colors.white),
              label: const Text(
                'Copy Link',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            )
          ],
        );
      },
    );
  }

  // Fixed _removeMessageFromUI function
  void _removeMessageFromUI(String messageId) {
    if (messageId.isEmpty) return;

    setState(() {
      bool messageFound = false;
      // Remove from all chats
      messages.forEach((chatId, messageList) {
        final initialLength = messageList.length;
        // ✅ Filter out null values before checking ID
        messageList
            .removeWhere((message) => _getMessageId(message) == messageId);
        if (messageList.length < initialLength) {
          messageFound = true;
        }
      });
      if (!messageFound) {}
    });
  }

// join group
// Method to show join group dialog
  void _showJoinGroupDialog() {
    final TextEditingController inviteLinkController = TextEditingController();
    bool isJoining = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1D29),
              // Dark background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4285F4), // Blue color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join a Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the invite link to join an existing group',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: inviteLinkController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'e.g. https://connect-frontend-1ogx.onrender.com/invite/group/...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2D3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste the complete invite link here',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isJoining ? null : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isJoining
                      ? null
                      : () async {
                          final inviteLink = inviteLinkController.text.trim();
                          if (inviteLink.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an invite link'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isJoining = true;
                          });

                          await _joinGroupWithLink(inviteLink);
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isJoining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Join Group'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Method to extract token from invite link
  String? _extractTokenFromInviteLink(String inviteLink) {
    try {
      // Parse the URL
      final uri = Uri.parse(inviteLink);

      // Extract the token from the path
      // Expected format: https://connect-frontend-1ogx.onrender.com/invite/group/TOKEN
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3 &&
          pathSegments[0] == 'invite' &&
          pathSegments[1] == 'group') {
        return pathSegments[2]; // This is the token
      }

      return null;
    } catch (e) {
      return null;
    }
  }

// Method to join group using invite link
  Future<void> _joinGroupWithLink(String inviteLink) async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final tokens = userData!.token;
    try {
      // Extract token from the invite link
      final token = _extractTokenFromInviteLink(inviteLink);

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid invite link format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Make API call to join group
      final response = await http.patch(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/user/join-group-using-invite/$token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokens',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Successfully joined the group!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh your groups list here if needed
        // await _refreshGroups();
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to join group'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to join group');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join group. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get current chat's pinned messages
  List<dynamic> get currentChatPinnedMessages {
    if (selectedChatId == null) {
      return [];
    }

    final pinnedMessages = pinnedMessagesByChat[selectedChatId!] ?? [];

    if (pinnedMessages.isNotEmpty) {
    } else {
      // Additional debugging
      bool chatExists = pinnedMessagesByChat.containsKey(selectedChatId!);

      if (chatExists) {}
    }

    return pinnedMessages;
  }

  void _pinMessage(dynamic message) {
    if (selectedChatId == null) {
      _showErrorSnackBar('No chat selected');
      return;
    }

    List<dynamic> currentPinned = currentChatPinnedMessages;

    if (currentPinned.length >= 3) {
      _showErrorSnackBar(
          'Only 3 messages can be pinned at a time in this chat');
      return;
    }

    String? messageId = _getMessageId(message);

    log('📌 Attempting to pin message: $messageId');
    log('   - Selected chat: $selectedChatId');
    log('   - Is temp ID: ${messageId?.startsWith('temp-')}');
    log('   - In recentlySent: ${_recentlySentMessages.contains(messageId)}');

    if (messageId == null || messageId.isEmpty) {
      log('❌ Pin failed: Invalid message ID');
      _showErrorSnackBar('Invalid message');
      return;
    }

    if (messageId.startsWith('temp-')) {
      log('❌ Pin failed: Message has temporary ID');
      _showErrorSnackBar(
          'Please wait for the message to be sent before pinning');
      return;
    }

    if (_recentlySentMessages.contains(messageId)) {
      log('❌ Pin failed: Message is still being sent');
      _showErrorSnackBar('Message is still being sent, please wait');
      return;
    }

    if (currentPinned.any((m) => _getMessageId(m) == messageId)) {
      log('❌ Pin failed: Message already pinned');
      _showErrorSnackBar('Message is already pinned in this chat');
      return;
    }

    // Find the actual message from the messages list
    final chatMessages = messages[selectedChatId] ?? [];
    final actualMessage = chatMessages.firstWhereOrNull(
      (msg) => _getMessageId(msg) == messageId,
    );

    if (actualMessage == null) {
      log('❌ Pin failed: Message not found in chat messages');
      log('   - Total messages in chat: ${chatMessages.length}');
      log('   - Looking for ID: $messageId');
      _showErrorSnackBar('Message not found');
      return;
    }

    log('✅ Message found, proceeding to pin');
    log('   - Message content: ${actualMessage.content}');
    log('   - Message ID: ${actualMessage.id}');

    // OPTIMISTIC UPDATE
    setState(() {
      if (pinnedMessagesByChat[selectedChatId!] == null) {
        pinnedMessagesByChat[selectedChatId!] = [];
      }
      pinnedMessagesByChat[selectedChatId!]!.add(actualMessage);
    });

    isGroup = selectedChat?.isGroup == true;

    log('📤 Emitting pinMessage to server');
    log('   - groupId: ${isGroup ? selectedChatId : null}');
    log('   - chatId: ${!isGroup ? selectedChatId : null}');
    log('   - messageId: $messageId');

    _socketService.pinMessage(
      groupId: selectedChat?.isGroup == true ? selectedChatId : null,
      chatId: selectedChat?.isGroup != true ? selectedChatId : null,
      messageId: messageId,
    );
  }

// Updated unpin message function
  void _unpinMessage(dynamic message) {
    if (selectedChatId == null) {
      _showErrorSnackBar('No chat selected');
      return;
    }

    String? messageId = _getMessageId(message);
    if (messageId!.isEmpty) {
      _showErrorSnackBar('Invalid message');
      return;
    }
    // OPTIMISTIC UPDATE: Remove message from pinned list immediately
    setState(() {
      pinnedMessagesByChat[selectedChatId!]
          ?.removeWhere((m) => _getMessageId(m) == messageId);

      // Remove empty lists to keep the map clean
      if (pinnedMessagesByChat[selectedChatId!]?.isEmpty == true) {
        pinnedMessagesByChat.remove(selectedChatId!);
      }
    });

    // Use SocketService to unpin message
    _socketService.unpinMessage(
      groupId: selectedChat?.isGroup == true ? selectedChatId : null,
      chatId: selectedChat?.isGroup != true ? selectedChatId : null,
      messageId: messageId,
    );
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Enhanced file upload handler with audio support
  Future<void> _handleFileUpload() async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select File Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Image'),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Video'),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
                ListTile(
                  leading: Icon(Icons.audiotrack),
                  title: Text('Audio'),
                  onTap: () => Navigator.pop(context, 'audio'),
                ),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Record Audio'),
                  onTap: () => Navigator.pop(context, 'record_audio'),
                ),
                ListTile(
                  leading: Icon(Icons.file_present),
                  title: Text('Document'),
                  onTap: () => Navigator.pop(context, 'document'),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: Icon(Icons.video_camera_back),
                  title: Text('Record Video'),
                  onTap: () => Navigator.pop(context, 'record_video'),
                ),
              ],
            ),
          );
        },
      );

      if (result != null) {
        File? selectedFile;

        switch (result) {
          case 'image':
            selectedFile = await _pickImageFromGallery();
            break;
          case 'video':
            selectedFile = await _pickVideoFromGallery();
            break;
          case 'audio':
            selectedFile = await _pickAudioFromStorage();
            break;
          case 'record_audio':
            selectedFile = await _recordAudio();
            break;
          case 'document':
            selectedFile = await _pickDocument();
            break;
          case 'camera':
            selectedFile = await _pickImageFromCamera();
            break;
          case 'record_video':
            selectedFile = await _pickVideoFromCamera();
            break;
        }

        if (selectedFile != null) {
          await _uploadFile(selectedFile);
        }
      }
    } catch (e) {
      _showSnackBar('Error selecting file: $e');
    }
  }

  Future<File?> _pickAudioFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<File?> _recordAudio() async {
    try {
      // Request permission
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        _showSnackBar('Microphone permission denied');
        return null;
      }

      // Show recording dialog
      return await showDialog<File?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AudioRecorderDialog();
        },
      );
    } catch (e) {
      _showSnackBar('Error recording audio: $e');
      return null;
    }
  }

  // Helper function to check if URL is a sticker
  bool _isStickerUrl(String content) {
    // Check for known sticker domains/patterns
    return content.contains('flaticon.com') ||
        content.contains('cdn-icons-png.flaticon.com') ||
        content.contains('sticker') ||
        content.contains('emoji');
  }

// Helper function to check if content is a file URL
  bool _isFileUrl(String content) {
    // First check if it's a sticker URL - if yes, it's NOT a file
    if (_isStickerUrl(content)) {
      return false;
    }
    try {
      final uri = Uri.parse(content);
      if (!uri.hasAbsolutePath) return false;

      final path = uri.path.toLowerCase();
      final fileExtensions = [
        '.jpg', '.jpeg', '.png', '.gif', '.webp', // Images
        '.mp4', '.avi', '.mov', '.wmv', '.flv', '.3gp', '.webm', // Videos
        '.mp3', '.aac', '.wav', '.ogg', '.m4a', '.flac', // Audio
        '.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx', // Documents
      ];

      return fileExtensions.any((ext) => path.endsWith(ext));
    } catch (e) {
      return false;
    }
  }

// Helper function to check if content contains URLs
  bool _containsUrl(String content) {
    final urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(content);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<File?> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

// Add video picking methods
  Future<File?> _pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    return video != null ? File(video.path) : null;
  }

  Future<File?> _pickVideoFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    return video != null ? File(video.path) : null;
  }

  Future<File?> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }

  Future<File?> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

// Updated upload file method with size validation
  Future<void> _uploadFile(File file) async {
    LoginResponseModel? userData = await _userPreferences.getUser();
    final token = userData!.token;

    // Validate file size before uploading
    bool isValidSize = await _validateFileSize(file);
    if (!isValidSize) {
      return; // Stop upload if file size exceeds limit
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/upload-message-file'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('messageFile', file.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        localFileManager.addFilePath(FileTypeFormat.media, result['fileUrl']);

        if (result['fileUrl'] != null) {
          // Get file info
          final fileInfo = {
            'name': file.path.split('/').last,
            'type': FileUtils.getFileType(file.path),
            'size': await file.length(),
          };

          // Send file message
          _sendFileMessage(result['fileUrl'], fileInfo);
          _showSnackBar('File uploaded successfully');
        } else {
          throw Exception('No file URL returned');
        }
      } else {
        throw Exception('File upload failed: ${response.statusCode}');
      }
    } catch (error) {
      _showSnackBar('Failed to upload file: $error');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _sendFileMessage(String fileUrl, Map<String, dynamic> fileInfo) {
    if (selectedChatId == null || currentUserId == null) return;

    final chat = selectedChat;
    final isGroup = chat?.isGroup ?? false;
    String? receiverId;

    if (isGroup) {
      receiverId = null;
    } else {
      if (pendingPrivateChatUserId != null) {
        receiverId = pendingPrivateChatUserId;
      } else {
        final otherParticipant = chat?.participants?.firstWhere(
          (p) => p.id != currentUserId,
          orElse: () => null as Participant,
        );
        receiverId = otherParticipant?.id;
      }
    }

    final tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

// Store reply information BEFORE clearing state
    final isReplying = showReplyPreview && replyingToMessage != null;
    final replyToMessageId = replyingToMessage?.id;

    // Create new file message
    final newMessage = Message(
      id: tempMessageId,
      content: fileUrl,
      timestamp: DateTime.now(),
      sender: Sender(
        id: currentUserId!,
        name: currentUserName ?? 'You',
        avatar: currentUserAvatar,
      ),
      isRead: false,
      messageType: 'file',
      fileInfo: FileInfo(
        name: fileInfo['name'],
        type: fileInfo['type'],
        size: fileInfo['size'],
        url: fileUrl,
      ),
      replyTo: isReplying
          ? ReplyTo(
              id: replyingToMessage!.id,
              content: replyingToMessage!.content,
              sender: replyingToMessage!.sender,
            )
          : null,
    );

    // Optimistic UI update
    setState(() {
      messages[selectedChatId!] = [
        ...(messages[selectedChatId!] ?? []),
        newMessage
      ];
    });

    _scrollToBottom();

    // Send via socket
    _socketService.sendMessage(
      senderId: currentUserId!,
      receiverId: isGroup ? null : receiverId,
      groupId: isGroup ? selectedChatId : null,
      content: fileUrl,
      messageType: 'file',
      mentions: [],
      replyToMessageId:
          isReplying ? replyToMessageId : null, // Use stored value

      // fileInfo: fileInfo,
      callback: (response) {
        if (response['success'] == true && response['messageId'] != null) {
          // Replace temporary ID with real ID
          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            final updatedMessages = chatMessages
                .map((msg) => msg.id == tempMessageId
                    ? Message(
                        id: response['messageId']!,
                        content: msg.content,
                        timestamp: msg.timestamp,
                        sender: msg.sender,
                        isRead: msg.isRead,
                        messageType: msg.messageType,
                        fileInfo: msg.fileInfo,
                        replyTo: msg.replyTo, // Preserve reply data
                      )
                    : msg)
                .toList();
            messages[selectedChatId!] = updatedMessages;
          });
        } else {
          // Remove temporary message on failure
          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            messages[selectedChatId!] =
                chatMessages.where((msg) => msg.id != tempMessageId).toList();
          });
          _showSnackBar('Failed to send file');
        }
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

// Add the sticker message bubble function

  Widget _buildStickerMessageBubble(Message message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // ✅ Show forwarded indicator
                  if (message.isForwarded == true && !isMe)
                    _buildForwardedHeader(message),

                  if (isGroup && !isMe)
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 16,
                          backgroundImage: CacheImageLoader(
                            message.originalSender?.avatar ??
                                message.sender.avatar,
                            'assets/default_avatar.png',
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          message.originalSender?.name ?? message.sender.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  // Reply preview if this message is a reply
                  if (message.replyTo != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyTo!.sender!.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            message.replyTo!.content!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  // Sticker container
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                      maxHeight: 200,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.content,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load sticker',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Reactions
                  if (message.reactions != null &&
                      message.reactions!.isNotEmpty)
                    _buildReactionRow(message.reactions!),

                  // Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: isMe ? Colors.grey[600] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isMe) _buildMessageStatus(message.status, isMe),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced message bubble with clickable links
  Widget _buildMessageBubble(Message message, bool isMe) {
    final bool isStickerUrl = _isStickerUrl(message.content);
    final bool isFileUrl = _isFileUrl(message.content);
    final bool hasFileInfo = message.fileInfo != null;

    // Check for sticker messages FIRST - before file check
    if (message.messageType == 'sticker' || isStickerUrl) {
      return _buildStickerMessageBubble(message, isMe);
    }
    // Then check for file messages
    else if (message.messageType == 'file' || hasFileInfo || isFileUrl) {
      return Column(
        children: [
          if (message.isForwarded == true && !isMe) ...[
            _buildForwardedHeader(message),
            const SizedBox(height: 4),
          ],
          if (isGroup && !isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 16,
                      backgroundImage: CacheImageLoader(
                          message.originalSender?.avatar ??
                              message.sender.avatar!,
                          ImageAssets.defaultProfileImg)),
                  const SizedBox(width: 8),
                  // Name
                  Text(
                    message.originalSender?.name ?? message.sender.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          _buildFileMessageBubble(message, isMe),
        ],
      );
    } else {
      return Column(
        children: [
          if (message.isForwarded == true && !isMe) ...[
            const SizedBox(height: 10),
            _buildForwardedHeader(message),
            // const SizedBox(height: 4),
          ],
          if (isGroup && !isMe)
            SizedBox(
              height: 1,
            ),
          if (isGroup && !isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 16,
                      backgroundImage: CacheImageLoader(
                          message.originalSender?.avatar ??
                              message.sender.avatar,
                          ImageAssets.defaultProfileImg)),
                  const SizedBox(width: 8),
                  // Name
                  Text(
                    message.originalSender?.name ?? message.sender.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.opensansRegular,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white
                                : const Color.fromARGB(255, 51, 133, 247),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // In your _buildMessageBubble method, replace the reply preview section with:
                              if (message.replyTo != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.grey[100]
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border(
                                      left: BorderSide(
                                        color:
                                            isMe ? Colors.blue : Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.replyTo!.sender?.name ??
                                            'Unknown',
                                        style: TextStyle(
                                          fontFamily: AppFonts.opensansRegular,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isMe
                                              ? Colors.blue[700]
                                              : Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Use the same preview logic for consistency
                                      _buildReplyContentPreview(
                                          message.replyTo!),
                                    ],
                                  ),
                                ),
                              ],

                              // Main message content container
                              Padding(
                                padding: EdgeInsets.fromLTRB(16,
                                    message.replyTo != null ? 8 : 12, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Forwarded indicator
                                    if (message.isForwarded == true) ...[
                                      // Row(
                                      //   children: [
                                      //     Icon(
                                      //       Icons.forward,
                                      //       size: 14,
                                      //       color: isMe
                                      //           ? Colors.grey[600]
                                      //           : Colors.white.withOpacity(0.8),
                                      //     ),
                                      //     const SizedBox(width: 4),
                                      //     Text(
                                      //       'Forwarded',
                                      //       style: TextStyle(
                                      //         fontSize: 12,
                                      //         color: isMe
                                      //             ? Colors.grey[600]
                                      //             : Colors.white
                                      //                 .withOpacity(0.8),
                                      //         fontStyle: FontStyle.italic,
                                      //         fontFamily:
                                      //             AppFonts.opensansRegular,
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      const SizedBox(height: 8),
                                    ],

                                    // Original sender info for forwarded messages
                                    if (message.isForwarded == true &&
                                        message.originalSender != null) ...[
                                      Text(
                                        'From: ${message.originalSender!.name}',
                                        style: TextStyle(
                                          fontFamily: AppFonts.opensansRegular,
                                          fontSize: 11,
                                          color: isMe
                                              ? Colors.grey[600]
                                              : Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 1,
                                        color: isMe
                                            ? Colors.grey[300]
                                            : Colors.white.withOpacity(0.2),
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                      ),
                                    ],

                                    // Message content with clickable links
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Show translation indicator if message is translated
                                        if (!isMe &&
                                            _translatedMessages
                                                .containsKey(message.id)) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? Colors.blue.shade50
                                                  : Colors.white
                                                      .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.translate,
                                                  size: 12,
                                                  color: isMe
                                                      ? Colors.blue.shade700
                                                      : Colors.white
                                                          .withOpacity(0.9),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Translated',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: isMe
                                                          ? Colors.blue.shade700
                                                          : Colors.white
                                                              .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: AppFonts
                                                          .opensansRegular),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        // Show translated or original content
                                        _buildMessageContent(
                                          !isMe &&
                                                  _translatedMessages
                                                      .containsKey(message.id)
                                              ? _translatedMessages[message.id]!
                                              : message.content,
                                          textColor: isMe
                                              ? Colors.black87
                                              : Colors.white,
                                        ),

                                        // Show loading indicator if translating
                                        if (_translatingMessages
                                            .contains(message.id)) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    isMe
                                                        ? Colors.grey.shade600
                                                        : Colors.white
                                                            .withOpacity(0.7),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Translating...',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily:
                                                      AppFonts.opensansRegular,
                                                  color: isMe
                                                      ? Colors.grey.shade600
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Timestamp and status row
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: AppFonts.opensansRegular,
                                        color: isMe
                                            ? Colors.grey[500]
                                            : Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      _buildMessageStatus(message.status, isMe),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Message reactions
                        if (message.reactions != null &&
                            message.reactions!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _buildReactionRow(message.reactions!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildForwardedHeader(Message message) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.forward,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            'Forwarded',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (message.originalSender != null) ...[
            const SizedBox(width: 4),
            Text(
              'from ${message.originalSender!.name}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyContentPreview(ReplyTo replyTo) {
    // Extract content and type from replyTo
    final content = replyTo.content ?? '';
    final senderName = replyTo.sender?.name ?? 'Unknown';

    // Simple detection based on content patterns
    if (content.contains('/sticker/') || content.contains('sticker')) {
      return Row(
        children: [
          Icon(Icons.emoji_emotions, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('Sticker', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    } else if (content.contains('/image/') ||
        content.contains('.jpg') ||
        content.contains('.png') ||
        content.contains('.jpeg')) {
      return Row(
        children: [
          Image.network(
            content,
            fit: BoxFit.contain,
            height: 80,
            width: 80,
          ),
        ],
      );
    } else if (content.contains('/video/') ||
        content.contains('.mp4') ||
        content.contains('.mov')) {
      return Row(
        children: [
          Icon(Icons.videocam, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('Video', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    } else if (content.contains('/video/') ||
        content.contains('.mp4') ||
        content.contains('.mov')) {
      return Row(
        children: [
          Icon(Icons.videocam, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('Video', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    } else if (content.contains('/pdf/') ||
        content.contains('.pdf') ||
        content.contains('.doc') ||
        content.contains('.zip')) {
      return Row(
        children: [
          Icon(Icons.picture_as_pdf, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('Pdf File', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    } else {
      // For text messages, show the actual content
      return Text(
        content,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildMessageContent(String content,
      {Color? textColor, List<Map<String, dynamic>>? mentions}) {
    // Extract mentions if not provided
    final messageMentions = mentions ?? _extractMentionsFromText(content);

    if (messageMentions.isEmpty) {
      // No mentions, use existing URL handling
      final urlRegex = RegExp(
        r'https?://[^\s]+',
        caseSensitive: false,
      );
      final matches = urlRegex.allMatches(content);

      if (matches.isEmpty) {
        return Text(
          content,
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: textColor ?? Colors.black87,
            height: 1.3,
          ),
        );
      }

      // Build with URLs
      List<TextSpan> spans = [];
      int lastEnd = 0;

      for (final match in matches) {
        if (match.start > lastEnd) {
          spans.add(TextSpan(
            text: content.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Colors.black87,
              height: 1.3,
            ),
          ));
        }

        final url = match.group(0)!;
        spans.add(
          TextSpan(
            text: url,
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              fontSize: 16,
              color: AppColors.blackColor,
              decoration: TextDecoration.underline,
              height: 1.3,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _openUrl(url),
          ),
        );

        lastEnd = match.end;
      }

      if (lastEnd < content.length) {
        spans.add(TextSpan(
          text: content.substring(lastEnd),
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: textColor ?? Colors.black87,
            height: 1.3,
          ),
        ));
      }

      return RichText(
        text: TextSpan(children: spans),
      );
    }

    // Build with mentions and URLs
    List<TextSpan> spans = [];
    int lastEnd = 0;

    // Sort mentions by start index
    final sortedMentions = List<Map<String, dynamic>>.from(messageMentions)
      ..sort(
          (a, b) => (a['startIndex'] as int).compareTo(b['startIndex'] as int));

    for (final mention in sortedMentions) {
      final startIndex = mention['startIndex'] as int;
      final endIndex = mention['endIndex'] as int;
      final userName = mention['userName'] as String;
      final userId = mention['userId'] as String;

      // Add text before mention
      if (startIndex > lastEnd) {
        final textBefore = content.substring(lastEnd, startIndex);
        spans.addAll(_buildTextWithUrls(textBefore, textColor));
      }

      // Add mention with orange color and tap handler
      spans.add(
        TextSpan(
          text: '@$userName',
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Get.toNamed(RouteName.clipProfieScreen, arguments: userId);
            },
        ),
      );

      lastEnd = endIndex;
    }

    // Add remaining text
    if (lastEnd < content.length) {
      final remainingText = content.substring(lastEnd);
      spans.addAll(_buildTextWithUrls(remainingText, textColor));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

// Helper method to build text spans with URL detection
  List<TextSpan> _buildTextWithUrls(String text, Color? textColor) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: textColor ?? Colors.black87,
            height: 1.3,
          ),
        ),
      ];
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              fontSize: 16,
              color: textColor ?? Colors.black87,
              height: 1.3,
            ),
          ),
        );
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: AppColors.blackColor,
            decoration: TextDecoration.underline,
            height: 1.3,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _openUrl(url),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 16,
            color: textColor ?? Colors.black87,
            height: 1.3,
          ),
        ),
      );
    }

    return spans;
  }

  Future<void> _openUrl(String url) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Open Link',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to open this link?',
              style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Open',
              style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );

    if (shouldOpen != true) return;

    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Could not open link');
      }
    } catch (e) {
      _showSnackBar('Invalid URL: $e');
    }
  }

// Enhanced default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

// Enhanced message status with modern styling
  Widget _buildMessageStatus(String status, bool isMyMessage) {
    if (!isMyMessage) return const SizedBox.shrink();

    switch (status.toLowerCase()) {
      case 'sent':
        return Icon(
          Icons.check,
          size: 16,
          color: Colors.grey[500],
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey[500],
        );
      case 'read':
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue[600],
        );
      default:
        return Icon(
          Icons.schedule,
          size: 16,
          color: Colors.grey[400],
        );
    }
  }

// Helper method to build profile picture

  Widget _buildProfilePicture(dynamic avatar) {
    String? imageUrl;

    // Extract image URL from avatar object - IMPROVED
    if (avatar != null) {
      if (avatar is Map<String, dynamic>) {
        imageUrl = avatar['imageUrl'] ?? avatar['url'];
      } else if (avatar is String) {
        imageUrl = avatar;
      }

      // Validate URL
      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (!imageUrl.startsWith('http')) {
          imageUrl = '${ApiUrls.baseUrl}$imageUrl';
        }
      } else {
        imageUrl = null;
      }
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 32,
                height: 35,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Error loading avatar: $error');
                  return _buildDefaultAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

// Helper method to build default avatar

  Widget _buildFormattedContentWithUrls(String content) {
    // First, parse the formatting and create text spans
    List<TextSpan> formattedSpans = _parseFormattedText(content);

    // Then, process each span to handle URLs
    List<TextSpan> finalSpans = [];

    for (TextSpan span in formattedSpans) {
      if (span.text != null && _containsUrl(span.text!)) {
        // This span contains URLs, split it further
        finalSpans.addAll(_processUrlsInTextSpan(span));
      } else {
        // No URLs, keep the span as is
        finalSpans.add(span);
      }
    }

    return RichText(
      text: TextSpan(
        children: finalSpans,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  List<TextSpan> _parseFormattedText(String text) {
    // Check for simple formatting (single format per message)
    if (_hasSimpleFormatting(text)) {
      return [_parseSimpleFormatting(text)];
    }

    // For complex formatting, parse multiple formats
    return _parseComplexFormatting(text);
  }

  List<TextSpan> _parseComplexFormatting(String text) {
    List<TextSpan> spans = [];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      // Find the next formatting marker
      int nextMarkerIndex = text.length;
      String nextMarker = '';

      // Look for formatting markers
      for (String marker in ['*', '_', '~']) {
        int index = text.indexOf(marker, currentIndex);
        if (index != -1 && index < nextMarkerIndex) {
          nextMarkerIndex = index;
          nextMarker = marker;
        }
      }

      // Add plain text before the marker (if any)
      if (nextMarkerIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, nextMarkerIndex),
          style: const TextStyle(fontSize: 16),
        ));
      }

      // If no more markers found, we're done
      if (nextMarkerIndex >= text.length || nextMarker.isEmpty) {
        break;
      }

      // Find the closing marker
      int closingIndex = text.indexOf(nextMarker, nextMarkerIndex + 1);

      if (closingIndex != -1) {
        // Extract the content between markers
        String content = text.substring(nextMarkerIndex + 1, closingIndex);

        // Apply formatting based on marker type
        TextStyle style = _getStyleForMarker(nextMarker);
        spans.add(TextSpan(
          text: content,
          style: style,
        ));

        // Move past the closing marker
        currentIndex = closingIndex + 1;
      } else {
        // No closing marker found, treat as plain text
        spans.add(TextSpan(
          text: text.substring(nextMarkerIndex),
          style: const TextStyle(fontSize: 16),
        ));
        break;
      }
    }

    return spans.isEmpty
        ? [TextSpan(text: text, style: const TextStyle(fontSize: 16))]
        : spans;
  }

  List<TextSpan> _processUrlsInTextSpan(TextSpan originalSpan) {
    final String text = originalSpan.text ?? '';
    final TextStyle baseStyle =
        originalSpan.style ?? const TextStyle(fontSize: 16);

    final urlRegex = RegExp(r'https?://[^\s]+');
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return [originalSpan];
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add clickable URL
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: baseStyle.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => FileUtils.openUrl(context, url, localFileManager),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  TextSpan _parseSimpleFormatting(String text) {
    String displayText = text;
    TextStyle style = const TextStyle(fontSize: 16);

    if (text.length > 2 && text.startsWith('*') && text.endsWith('*')) {
      // Bold
      displayText = text.substring(1, text.length - 1);
      style = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    } else if (text.length > 2 && text.startsWith('_') && text.endsWith('_')) {
      // Italic
      displayText = text.substring(1, text.length - 1);
      style = const TextStyle(fontSize: 16, fontStyle: FontStyle.italic);
    } else if (text.length > 2 && text.startsWith('~') && text.endsWith('~')) {
      // Underline
      displayText = text.substring(1, text.length - 1);
      style =
          const TextStyle(fontSize: 16, decoration: TextDecoration.underline);
    }

    return TextSpan(text: displayText, style: style);
  }

  bool _hasSimpleFormatting(String text) {
    return (text.length > 2 && text.startsWith('*') && text.endsWith('*')) ||
        (text.length > 2 && text.startsWith('_') && text.endsWith('_')) ||
        (text.length > 2 && text.startsWith('~') && text.endsWith('~'));
  }

// NEW: Get TextStyle for formatting markers
  TextStyle _getStyleForMarker(String marker) {
    switch (marker) {
      case '*':
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
      case '_':
        return const TextStyle(fontSize: 16, fontStyle: FontStyle.italic);
      case '~':
        return const TextStyle(
            fontSize: 16, decoration: TextDecoration.underline);
      default:
        return const TextStyle(fontSize: 16);
    }
  }

  // Enhanced file message bubble with audio support

  Widget _buildFileMessageBubble(Message message, bool isMe) {
    FileInfo? fileInfo = message.fileInfo;
    String fileUrl = message.content;
    String fileName = '';
    String fileType = '';
    String fileSize = '';

    if (fileInfo != null) {
      fileName = fileInfo.name;
      fileType = fileInfo.type;
      fileSize = _formatFileSize(fileInfo.size);
    } else {
      try {
        final uri = Uri.parse(fileUrl);
        fileName = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'Unknown File';
        fileType = FileUtils.getFileType(fileName);
      } catch (e) {
        fileName = 'Unknown File';
        fileType = 'application/octet-stream';
      }
    }

    final isImage = fileType.startsWith('image/');
    final isVideo = fileType.startsWith('video/');
    final isAudio = fileType.startsWith('audio/');

    // Colors and border radius for sent and received
    final bgColor = isMe ? Colors.white : Color.fromARGB(255, 26, 96, 196);
    final textColor = isMe ? Colors.black87 : Colors.white;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMe ? 12 : 0),
      bottomRight: Radius.circular(isMe ? 0 : 12),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview - UPDATED
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      child: GestureDetector(
                        onTap: () => FileUtils.showImageFullScreen(
                            context, fileUrl, fileName, localFileManager),
                        child: Stack(
                          children: [
                            Image.network(
                              fileUrl,
                              width: MediaQuery.of(context).size.width * 0.75,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error,
                                          color: Colors.red, size: 40),
                                      SizedBox(height: 8),
                                      Text('Failed to load image'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // Optional: Add a small overlay with file size
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  fileSize,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Video Preview - UPDATED
                  else if (isVideo)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      child: GestureDetector(
                        onTap: () => FileUtils.showVideoFullScreen(
                            context, fileUrl, fileName, localFileManager),
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.75,
                          color: Colors.black,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Video thumbnail placeholder
                              Container(
                                color: Colors.black87,
                                child: Icon(
                                  Icons.video_library,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              // Play button overlay
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              // File size overlay
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.videocam,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        fileSize,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Audio Preview - UPDATED
                  else if (isAudio)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => FileUtils.showAudioPlayer(
                            context, fileUrl, fileName, localFileManager),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.blue[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Audio Message',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fileSize,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMe
                                          ? Colors.grey[600]
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.audiotrack,
                              color: isMe ? Colors.blue : Colors.blue[300],
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    )
                  // Document/Other files
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => FileUtils.openFile(
                            context, fileUrl, fileName, localFileManager),
                        child: Row(
                          children: [
                            Icon(
                              _getFileIcon(fileType),
                              color: isMe ? Colors.blue : Colors.blue[300],
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (fileInfo?.size != null)
                                    Text(
                                      fileSize,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe
                                            ? Colors.grey[600]
                                            : Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isImage || isVideo
                                ? Colors.white.withOpacity(0.9)
                                : (isMe ? Colors.grey[600] : Colors.white70),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatus(message.status, isMe),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (message.reactions != null && message.reactions!.isNotEmpty)
              _buildReactionRow(message.reactions!),
          ],
        ),
      ),
    );
  }

  //imageuploadingendshere
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.startsWith('image/')) {
      return Icons.image;
    } else if (fileType.startsWith('video/')) {
      return Icons.videocam;
    } else if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('word') || fileType.contains('doc')) {
      return Icons.description;
    } else if (fileType.contains('excel') || fileType.contains('sheet')) {
      return Icons.table_chart;
    } else if (fileType.contains('text')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  void initState() {
    super.initState();
    Get.put(UnreadCountController());
    Get.put(GroupUnreadCountController());
    _scrollController.addListener(_onScroll);
    _initScrollListener();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _generateInviteLink();
    _initializeChat();
    _connectSocketFirst();
    _setupSocketListeners();
    _socketService.messageHistoryStream.listen((data) {
      log("Handling messageHistory from stream");
      if (mounted) _handlePrivateMessageHistory(data);
    });
    _loadUserProfile();
    _cleanupMessageKeys();
    final dynamic args = Get.arguments;
    final Map<String, dynamic>? notificationData =
        args is Map<String, dynamic> ? args : null;
    final String? directUserId = args is String ? args : null;

    log("Arguments type: ${args.runtimeType}");
    if (notificationData != null) {
      log("From notification data: ${notificationData['isfromnoticlick']}");
      log("From notification chat id: ${notificationData['chatId']}");
      _refreshChatList();
    } else if (directUserId != null) {
      log("Direct messaging with userId: $directUserId");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeChat();
      await _connectSocketFirst();

      if (notificationData != null &&
          notificationData['isfromnoticlick'] == true) {
        _selectChat(notificationData['chatId']);
      } else if (widget.directUserId != null) {
        log(" Starting direct chat after init");
        await _initiateDirectChat(widget.directUserId!);
      }

      if (mounted) setState(() => loading = false);
    });
  }

  Future<void> _connectSocketFirst() async {
    final userData = await _userPreferences.getUser();
    final token = userData?.token;

    if (token != null) {
      await _socketService.connect(ApiUrls.baseUrl, token);
    }
  }

  Future<void> _initiateDirectChat(String targetUserId) async {
    if (currentUserId == null) {
      if (mounted) setState(() => loading = false);
      _showSnackBar('Unable to start chat: User not authenticated');
      return;
    }

    try {
      //Check if chat already exists
      final existingChat = directChats.firstWhereOrNull(
        (chat) => chat.participants?.any((p) => p.id == targetUserId) == true,
      );

      if (existingChat != null) {
        log("Existing chat found: ${existingChat.id}");
        if (mounted) {
          setState(() {
            selectedChatId = existingChat.id;
            showChatList = false;
            showGroupInfo = false;
            selectedSection = 'direct';
            loading = false;
          });
        }
        _selectChat(existingChat.id);
        return;
      }

      //Show loading
      if (mounted) setState(() => loading = true);

      // Join private room
      _socketService.joinPrivateRoom(
        currentUserId!,
        targetUserId,
        (response) async {
          log("joinPrivateRoom callback response: $response");

          // Check for success (now chatId comes from roomId in messageHistory)
          if (response['success'] == true && response['chatId'] != null) {
            final newChatId = response['chatId'];
            final messages = response['messages'] ?? [];

            log("Room joined successfully. ChatId: $newChatId");

            // Update UI immediately
            if (mounted) {
              setState(() {
                selectedChatId = newChatId;
                pendingPrivateChatUserId = targetUserId;
                isNewPrivateChat = true;
                showChatList = false;
                showGroupInfo = false;
                selectedSection = 'direct';
                loading = false;
                chatMessages[newChatId] = [];
              });
            }

            // If server already sent messages, handle them
            if (messages.isNotEmpty) {
              _handlePrivateMessageHistory({
                'roomId': newChatId,
                'messages': messages,
                'status': 200,
              });
            }
            // Refresh chat list in background
            await _fetchPrivateChats();
            // Select chat (this should now work)
            if (mounted) {
              _selectChat(newChatId);
            }
          } else {
            log("❌ Failed to join room: ${response['message']}");
            if (mounted) setState(() => loading = false);
            _showSnackBar(response['message'] ?? 'Failed to start chat');
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => loading = false);
      log("🚨 Direct chat error: $e");
      _showSnackBar('Unable to start chat: $e');
    }
  }

  @override
  void dispose() {
    //  _olderPrivateMessagesSubscription?.cancel();
    // _olderGroupMessagesSubscription?.cancel();
    ChatOpenTracker.currentChatId = null;
    adminAddedSubscription?.cancel();
    _pinnedMessageSubscription.cancel();
    _errorSubscription.cancel();
    _messagesReadSubscription?.cancel();
    _messageReactionSubscription?.cancel();
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _groupDetailsSubscription?.cancel();
    _privateMessageSubscription?.cancel();
    _groupDeletedSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _newMessageSubscription?.cancel();
    _unpinnedMessageSubscription.cancel();
    _messageDeletedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      // First try to get from SharedPreferences
      final profile = await _prefs.getUserProfile();
      if (profile != null) {
        setState(() {
          currentUserProfile = profile;
        });
      } else {
        await _profileController.userListApi();
        if (_profileController.rxRequestStatus.value == Looks.COMPLETED) {
          setState(() {
            currentUserProfile =
                _profileController.userList.value as UserProfileModel?;
          });

          await _prefs.saveUserProfile(
              _profileController.userList.value as UserProfileModel);
        }
      }
    } catch (e) {}
  }

  Future<void> _initializeChat() async {
    try {
      LoginResponseModel? userData = await _userPreferences.getUser();

      // ❌ DO NOT CONNECT SOCKET HERE
      // _socketService.connect(ApiUrls.baseUrl, token);

      await _fetchGroups();
      await _fetchPrivateChats();

      if (mounted) {
        setState(() {
          currentUserId = userData?.user.id;
          currentUserName = userData?.user.fullName;
          currentUserAvatar = userData?.user.avatar.imageUrl ??
              'https://www.canto.com/blog/image-url/';
          loading = false;
        });
      }

      _animationController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

// Add this method to handle refresh for chat list
  Future<void> _refreshChatList() async {
    try {
      // Show loading state
      setState(() {
        loading = true;
      });

      // Fetch fresh data
      await _fetchGroups();
      await _fetchPrivateChats();
      // Trigger sorting after refresh
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sortChatsSafely();
      });

      // You can also refresh user data if needed
      LoginResponseModel? userData = await _userPreferences.getUser();
      if (userData != null) {
        setState(() {
          currentUserId = userData.user.id;
          currentUserName = userData.user.fullName;
          currentUserAvatar = userData.user.avatar.imageUrl ??
              'https://www.canto.com/blog/image-url/';
        });
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sortChatsSafely() {
    setState(() {});
  }

  void _setupSocketListeners() {
    adminAddedSubscription = _socketService.adminAddedStream.listen((data) {
      _handleAdminAdded(data);
    });
    // Add new listener for read receipts
    _messagesReadSubscription =
        _socketService.messagesReadStream.listen((data) {
      _handleMessagesRead(data);
    });
    // Listen for all incoming messages (both group and private)
    _messageReactionSubscription =
        _socketService.messageReactionUpdatedStream.listen((data) {
      _handleMessageReactionUpdated(data);
    });
    // Add new listener for unread count updates
    _unreadCountSubscription = _socketService.unreadCountStream.listen((data) {
      _handleUnreadCountUpdate(data);
    });

    _messageSubscription = _socketService.messageStream.listen((data) {
      _handleReceiveMessage(data);

      String? chatId =
          data["group"] ?? data["groupId"] ?? data["chat"] ?? data["chatId"];
      if (chatId == null) return;

      final lastMessageText = data["message"]?["content"] ??
          data["message"]?["text"] ??
          data["lastMessage"] ??
          "";

      final lastTimestamp = parseTimestamp(data["message"]?["createdAt"] ??
          data["message"]?["timestamp"] ??
          data["message"]?["sentAt"] ??
          data["message"]?["updatedAt"]);

      final index = allChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final old = allChats[index];

        final updatedChat = Chat(
          id: old.id,
          name: old.name,
          avatar: old.avatar,
          lastMessage: lastMessageText,
          timestamp: lastTimestamp, // ⬅ NEW TIMESTAMP
          isGroup: old.isGroup,
          isOnline: old.isOnline,
          senderName: old.senderName,
          participants: old.participants,
          pinnedMessages: old.pinnedMessages,
        );

        setState(() {
          allChats[index] = updatedChat;

          // sort like WhatsApp
          allChats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }

      // unread logic (already perfect)
    });

    _groupDetailsSubscription =
        _socketService.groupDetailsStream.listen((data) {
      _handleGroupDetails(data);
    });
    // Add group deleted listener
    _groupDeletedSubscription =
        _socketService.groupDeletedStream.listen((data) {
      _handleGroupDeleted(data);
    });
    _messageDeletedSubscription =
        _socketService.messageDeletedStream.listen((data) {
      _handleMessageDeleted(data);
    });
    // _privateMessageSubscription =
    //     _socketService.privateMessageHistoryStream.listen((data) {
    //   _handlePrivateMessageHistory(data);
    // });

    // Add new message listener for forwarded messages
    _newMessageSubscription = _socketService.newMessageStream.listen((data) {
      try {
        // Handle regular new messages
        if (data['type'] == 'newMessage') {
          final message = Message.fromJson(data['message']);
          _addNewMessage(message, data['chatId']);
        }

        // Handle forwarded messages
        else if (data['type'] == 'forwardedMessage') {
          final forwardedMessage = Message.fromJson(data['message']);
          final targetChatId = data['chatId'];

          // Add forwarded message to the target chat
          _addNewMessage(forwardedMessage, targetChatId);

          // Show notification if not in the target chat
          if (selectedChatId != targetChatId) {
            _showForwardedMessageNotification(forwardedMessage, targetChatId);
          }
        }

        // Handle any new message (including forwarded)
        else {
          final message = Message.fromJson(data);
          final chatId = data['chatId'] ?? selectedChatId;
          if (chatId != null) {
            _addNewMessage(message, chatId);
          }
        }
      } catch (e) {}
    });

    // Listen for pinned messages
    // Listen for pinned messages - now mainly for syncing with other users
    _pinnedMessageSubscription =
        _socketService.pinnedMessageStream.listen((data) {
      final messageId = data['messageId']?.toString();
      final chatId = data['chatId']?.toString() ?? data['groupId']?.toString();
      final messageData =
          data['message']; // The full message object from server

      if (messageId != null && chatId != null && messageData != null) {
        setState(() {
          if (pinnedMessagesByChat[chatId] == null) {
            pinnedMessagesByChat[chatId] = [];
          }

          // Check if message is already in the list (from optimistic update)
          bool alreadyExists = pinnedMessagesByChat[chatId]!
              .any((m) => _getMessageId(m) == messageId);

          if (!alreadyExists) {
            // This handles cases where another user pinned the message
            pinnedMessagesByChat[chatId]!.add(messageData);
          } else {
            // Update the existing message with server data (in case of any differences)
            int index = pinnedMessagesByChat[chatId]!
                .indexWhere((m) => _getMessageId(m) == messageId);
            if (index != -1) {
              pinnedMessagesByChat[chatId]![index] = messageData;
            }
          }
        });

        // Only show success message if this is NOT the current user's action
        // (we already showed it optimistically)
        if (chatId == selectedChatId && data['userId'] != currentUserId) {
          _showSuccessSnackBar('Message pinned by another user');
        }
      }
    });

    // Listen for unpinned messages
    _unpinnedMessageSubscription =
        _socketService.unpinnedMessageStream.listen((data) {
      final messageId = data['messageId']?.toString();
      final chatId = data['chatId']?.toString() ?? data['groupId']?.toString();

      if (messageId != null && chatId != null) {
        setState(() {
          pinnedMessagesByChat[chatId]
              ?.removeWhere((m) => _getMessageId(m) == messageId);

          // Remove empty lists to keep the map clean
          if (pinnedMessagesByChat[chatId]?.isEmpty == true) {
            pinnedMessagesByChat.remove(chatId);
          }
        });

        // Only show success message if this is the current chat
        if (chatId == selectedChatId) {
          _showSuccessSnackBar('Message unpinned');
        }
      }
    });
    // Listen for errors
    _errorSubscription = _socketService.errorStream.listen((data) {
      _showErrorSnackBar(data['message']?.toString() ?? 'An error occurred');
    });
  }

  void _startEditingMessage(Message message) {
    // Only check if it's the user's own message
    if (message.sender.id != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit your own messages'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _editingMessage = message;
      _editMessageController.text = message.content;
      _isEditingMode = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _editMessageController.clear();
      _isEditingMode = false;
    });
  }

  void _saveEditedMessage() {
    if (_editingMessage == null || _editMessageController.text.trim().isEmpty) {
      return;
    }

    final newContent = _editMessageController.text.trim();
    final messageId = _editingMessage!.id;

    print('Editing message with ID: $messageId');
    print('New content: $newContent');

    // Immediately update the UI (optimistic update)
    setState(() {
      for (String chatId in messages.keys) {
        messages[chatId] = messages[chatId]!.map((msg) {
          if (msg.id == messageId) {
            return msg.copyWith(
              content: newContent,
              isEdited: true,
              editedAt: DateTime.now(),
            );
          }
          return msg;
        }).toList();
      }
    });

    // Clear editing mode immediately
    _cancelEditing();

    // Send to server (for other users and persistence)
    _socketService.editMessage(
      messageId: messageId,
      userId: currentUserId!,
      newContent: newContent,
      callback: (success, message) {
        if (success) {
          // Message already updated in UI, just show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message edited successfully')),
          );
        } else {
          // Revert the optimistic update on failure
          setState(() {
            for (String chatId in messages.keys) {
              messages[chatId] = messages[chatId]!.map((msg) {
                if (msg.id == messageId) {
                  return msg.copyWith(
                    content: _editingMessage!.content, // Revert to original
                    isEdited: _editingMessage!.isEdited,
                    editedAt: _editingMessage!.editedAt,
                  );
                }
                return msg;
              }).toList();
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to edit message: ${message ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    _clearInputStates();
  }

  // Handler for older private messages
  void _handleOlderPrivateMessages(Map<String, dynamic> data) {
    setState(() {
      _isLoadingOlderMessages = false; // Always reset loading state
    });

    if (data['status'] == 200) {
      final String chatId = data['roomId'];
      final List<dynamic> newMessages = data['messages'] ?? [];
      final bool hasMore = data['hasMore'] ?? false;

      setState(() {
        _hasMoreMessages[chatId] = hasMore;

        if (newMessages.isNotEmpty) {
          // Convert to Message objects
          final List<Message> messageObjects = newMessages.map((msgData) {
            return Message.fromJson(msgData);
          }).toList();

          // Prepend to existing messages
          final existingMessages = messages[chatId] ?? [];
          messages[chatId] = [...messageObjects, ...existingMessages];

          // Maintain scroll position
          _cleanupMessageKeys();
          _maintainScrollPosition(newMessages.length);
        }
      });
    } else {
      _showSnackBar('Failed to load older messages: ${data['message']}');
    }
  }

  // Fixed: Direct callback handler for older group messages
  void _handleOlderGroupMessages(Map<String, dynamic> data) {
    setState(() {
      _isLoadingOlderMessages = false; // Always reset loading state
    });

    if (data['status'] == 200) {
      final String groupId = data['groupId'];
      final List<dynamic> newMessages = data['messages'] ?? [];
      final bool hasMore = data['hasMore'] ?? false;

      setState(() {
        _hasMoreMessages[groupId] = hasMore;

        if (newMessages.isNotEmpty) {
          // Convert to Message objects
          final List<Message> messageObjects = newMessages.map((msgData) {
            return Message.fromJson(msgData);
          }).toList();

          // Prepend to existing messages
          final existingMessages = messages[groupId] ?? [];
          messages[groupId] = [...messageObjects, ...existingMessages];
          _cleanupMessageKeys();
          // Maintain scroll position
          _maintainScrollPosition(newMessages.length);
        }
      });
    } else {
      _showSnackBar('Failed to load older messages: ${data['message']}');
    }
  }

  void _maintainScrollPosition(int newMessageCount) {
    if (newMessageCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final currentScrollOffset = _scrollController.offset;
          final itemHeight = 80.0; // Adjust based on your actual message height
          final newScrollOffset =
              currentScrollOffset + (newMessageCount * itemHeight);

          _scrollController.jumpTo(newScrollOffset.clamp(
              0.0, _scrollController.position.maxScrollExtent));
        }
      });
    }
  }

// Dialog to show group creation limit warning
  Future<void> _showGroupLimitWarningDialog(
      int currentCount, int maxLimit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Group Creation Limit Reached',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have reached your group creation limit.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.red[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Limit Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Groups created: $currentCount'),
                    Text('Maximum allowed: $maxLimit'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              if (maxLimit <= 1) // Show upgrade message for basic users
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.blue[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create unlimited groups with premium subscription!',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              if (maxLimit >
                  1) // Show alternative suggestion for users with some limit
                Text(
                  'To create more groups, consider deleting some existing groups or upgrading your subscription.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            if (maxLimit <= 1) // Show upgrade button for basic users
              TextButton(
                child: Text(
                  'Upgrade Now',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to premium upgrade page
                  // _navigateToUpgradePage();
                },
              ),
            if (maxLimit >
                1) // Show manage groups button for users with some limit
              TextButton(
                child: Text(
                  'Manage Groups',
                  style: TextStyle(color: Colors.orange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to group management to delete groups
                  // _navigateToGroupManagement();
                },
              ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Add this method to validate group creation limit
  Future<bool> _validateGroupCreationLimit() async {
    try {
      // Get current user's group limit from profile
      final groupLimit =
          currentUserProfile?.subscriptionFeatures?.publicGroup ??
              1; // Default 1 if not found

      // Get current number of groups created by user
      final currentGroupCount = await _getCurrentUserGroupCount();

      if (currentGroupCount >= groupLimit) {
        // Show warning dialog
        await _showGroupLimitWarningDialog(currentGroupCount, groupLimit);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

// Method to count groups created by current user
  Future<int> _getCurrentUserGroupCount() async {
    try {
      // Fetch current groups
      final fetchedGroups = await _chatService.getMyGroups();

      // Get current user ID
      LoginResponseModel? userData = await _userPreferences.getUser();
      final currentUserId =
          userData?.user.id; // Adjust based on your user model structure

      if (currentUserId == null) {
        throw Exception('Current user ID not found');
      }

      // Count groups created by current user (where user is the creator)
      int createdGroupsCount = 0;
      for (var group in fetchedGroups) {
        if (group.createdBy!.id == currentUserId) {
          createdGroupsCount++;
        }
      }

      return createdGroupsCount;
    } catch (e) {
      return 0;
    }
  }

  void _handleUnreadCountUpdate(Map<String, dynamic> data) {
    final chatId = data['chatId'] as String?;
    final unreadCount = data['unreadCount'] as int? ?? 0;
    final chatType = data['chatType'] as String?;

    if (chatId != null) {
      if (!mounted) return;

      // setState(() {
      //   unreadCounts[chatId] = unreadCount;
      // });
    }
  }

//deletemessage
  void _handleMessageDeleted(Map<String, dynamic> data) {
    final messageId = data['messageId'];

    if (messageId != null) {
      setState(() {
        // Remove message from your messages map
        // Iterate through all chat IDs and remove the message from each list
        messages.forEach((chatId, messageList) {
          messageList
              .removeWhere((message) => _getMessageId(message) == messageId);
        });
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteMessage(dynamic message) {
    if (message == null) return;

    final messageId = _getMessageId(message);
    final currentid =
        currentUserId!; // Implement this method to get current user ID

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Delete Message',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: TextStyle(
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteMessage(messageId!, currentid);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performDeleteMessage(String messageId, String userId) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    _socketService.deleteMessage(
      messageId: messageId,
      userId: userId,
      callback: (success, message) {
        // Hide loading indicator
        Navigator.of(context).pop();

        if (success) {
          _removeMessageFromUI(messageId);
          Utils.toastMessageCenter('Message Deleted Succesfully');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message ?? 'Failed to delete message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

//admin code
  void _handleAdminAdded(Map<String, dynamic> data) {
    // Handle the admin added event
    String? userId = data['userId'];
    String? groupId = data['groupId'];
    String? userName = data['userName'];

    if (groupId != null && userName != null) {
      setState(() {
        // Update your groups/members list
        // Example implementation:
        final groupIndex = groups.indexWhere((group) => group.id == groupId);
        if (groupIndex != -1) {
          groups[groupIndex].admins!.add(userName);
        }
      });

      _showSnackBar('New admin added to group');
    }
  }

  void _handleMessagesRead(Map<String, dynamic> data) {
    final chatId = data['chatId'];
    final userId = data['userId'];

    // Update your local message map to mark messages as read
    setState(() {
      // Get the messages for the specific chat
      if (messages.containsKey(chatId)) {
        final chatMessages = messages[chatId]!;

        // Update messages where the receiver (userId) is reading messages from other senders
        for (var message in chatMessages) {
          if (message.sender.id != userId) {
            message.status = 'read';
          }
        }
      }
    });
  }

  void markChatAsRead(String chatId, String currentUserId) {
    _socketService.markMessagesAsRead(
      chatId: chatId,
      userId: currentUserId,
    );
    // setState(() {
    //   unreadCounts[chatId] = 0;
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sortChatsSafely();
    });
  }

  void _handleMessageReactionUpdated(Map<String, dynamic> updatedMessage) {
    final String messageIdToUpdate = updatedMessage['_id'];

    if (selectedChatId == null) return;

    log('🔄 Updating reactions for message: $messageIdToUpdate');
    log('🔄 Updated message data: $updatedMessage');

    setState(() {
      List<Message> currentChatMessages = messages[selectedChatId!] ?? [];

      for (int i = 0; i < currentChatMessages.length; i++) {
        if (currentChatMessages[i].id == messageIdToUpdate) {
          // Properly parse reactions with the updated method
          final reactionsData = updatedMessage['reactions'] as List?;
          if (reactionsData != null) {
            log('📊 Processing ${reactionsData.length} reactions');

            currentChatMessages[i].reactions =
                reactionsData.map((reactionData) {
              log('👤 Reaction data: $reactionData'); // Log each reaction

              try {
                final reaction = Reaction.fromJson(reactionData);
                log('✅ Parsed reaction: emoji=${reaction.emoji}, user=${reaction.user.name}');
                return reaction;
              } catch (e) {
                log('❌ Error parsing reaction: $e');
                // Return a fallback reaction
                return Reaction(
                  user: Sender(
                    id: reactionData['user']?['_id'] ?? '',
                    name: reactionData['user']?['fullName'] ?? 'Unknown User',
                    avatar: null,
                  ),
                  emoji: reactionData['emoji'] ?? '❓',
                );
              }
            }).toList();

            log('✅ Updated ${currentChatMessages[i].reactions?.length ?? 0} reactions for message');
          } else {
            currentChatMessages[i].reactions = [];
            log('🔄 No reactions found, setting empty list');
          }
          break;
        }
      }
    });
  }

  void _handleReaction(String messageId, String emoji) {
    if (selectedChatId == null || currentUserId == null) return;

    _socketService.reactToMessage(
      messageId: messageId,
      userId: currentUserId!,
      emoji: emoji,
    );
  }

  void _showEmojiReactions(String messageId) {
    final availableEmojis = _getAvailableEmojis();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'React with an emoji',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${availableEmojis.length} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: availableEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = availableEmojis[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _handleReaction(messageId, emoji);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (availableEmojis.length < emojiReactions.length) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade your subscription to access ${emojiReactions.length - availableEmojis.length} more emoji reactions!',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionRow(List<Reaction> reactions) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    // Group reactions by emoji with proper user information
    Map<String, List<Reaction>> groupedReactions = {};
    for (var reaction in reactions) {
      if (groupedReactions.containsKey(reaction.emoji)) {
        groupedReactions[reaction.emoji]!.add(reaction);
      } else {
        groupedReactions[reaction.emoji] = [reaction];
      }
    }

    // Sort by count (highest first) and take only top 3
    final sortedEntries = groupedReactions.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final displayEmojis = sortedEntries.take(3).toList();
    final remainingCount =
        sortedEntries.length > 3 ? sortedEntries.length - 3 : 0;
    final totalReactions = reactions.length;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: [
          // Display top 3 emojis
          ...displayEmojis.map((entry) {
            String emoji = entry.key;
            List<Reaction> emojiReactions = entry.value;
            bool hasCurrentUserReacted =
                emojiReactions.any((r) => r.user.id == currentUserId);

            return GestureDetector(
              onTap: () {
                // Show all reactions when tapped
                // _showAllReactionsBottomSheet(groupedReactions);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasCurrentUserReacted
                      ? Colors.blue[100]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: hasCurrentUserReacted
                      ? Border.all(color: Colors.blue, width: 1)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      emojiReactions.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasCurrentUserReacted
                            ? Colors.blue[700]
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Show "+X more" if there are more than 3 emoji types
          if (remainingCount > 0)
            GestureDetector(
              onTap: () {
                _showAllReactionsBottomSheet(groupedReactions);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$remainingCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllReactionsBottomSheet(
      Map<String, List<Reaction>> groupedReactions) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emoji tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groupedReactions.length,
                itemBuilder: (context, index) {
                  final entry = groupedReactions.entries.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        // _showReactionDetails(entry.key, entry.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(entry.key,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              entry.value.length.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // All reactions list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groupedReactions.length,
                itemBuilder: (context, index) {
                  final entry = groupedReactions.entries.elementAt(index);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(entry.key,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value.length} ${entry.value.length == 1 ? 'person' : 'people'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...entry.value.map((reaction) {
                        final isCurrentUser = reaction.user.id == currentUserId;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            backgroundImage: reaction.user.avatar != null &&
                                    reaction.user.avatar!.isNotEmpty
                                ? CacheImageLoader(
                                    reaction.user.avatar!,
                                    ImageAssets.defaultProfileImg,
                                  )
                                : null,
                            child: reaction.user.avatar == null ||
                                    reaction.user.avatar!.isEmpty
                                ? Text(
                                    _getInitials(reaction.user.name),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          title: Row(
                            children: [
                              Text(
                                reaction.user.name,
                                style: TextStyle(
                                  fontWeight: isCurrentUser
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionDetails(String emoji, List<Reaction> reactions) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Text(
                  '${reactions.length} ${reactions.length == 1 ? 'person' : 'people'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reactions List
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reactions.length,
                itemBuilder: (context, index) {
                  final reaction = reactions[index];
                  final user = reaction.user;
                  final isCurrentUser = user.id == currentUserId;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          user.avatar != null && user.avatar!.isNotEmpty
                              ? CacheImageLoader(
                                  user.avatar!,
                                  ImageAssets.defaultProfileImg,
                                )
                              : null,
                      child: user.avatar == null || user.avatar!.isEmpty
                          ? Text(
                              _getInitials(user.name),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFonts.opensansRegular),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to add new message to chat (fixed for your data structure)
  void _addNewMessage(Message message, String chatId) {
    setState(() {
      final chatIndex = allChats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        // Create updated chat with new last message and timestamp
        final updatedChat = Chat(
          id: allChats[chatIndex].id,
          name: allChats[chatIndex].name,
          avatar: allChats[chatIndex].avatar,
          lastMessage: message.content,
          timestamp: message.timestamp,
          // Use timestamp, not lastMessageTime
          // unread:
          //     allChats[chatIndex].unread + (selectedChatId == chatId ? 0 : 1),
          isGroup: allChats[chatIndex].isGroup,
          isOnline: allChats[chatIndex].isOnline,
          senderName: message.sender.name,
          participants: allChats[chatIndex].participants,
        );

        allChats[chatIndex] = updatedChat;

        if (selectedChatId == chatId) {
          (messages as Map<String, Message>)[message.id] = message;
        } else if (selectedChatId == chatId && messages is List) {
          (messages as List<Message>).add(message);
        }

        final chat = allChats.removeAt(chatIndex);
        allChats.insert(0, chat);
      }
    });
  }

  void _showForwardedMessageNotification(Message message, String chatId) {
    final chat = allChats.firstWhereOrNull((c) => c.id == chatId);
    if (chat != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New forwarded message in ${chat.name}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              setState(() {
                selectedChatId = chatId;
                _selectChat(chatId); //
              });
            },
          ),
        ),
      );
    }
  }

// Enhanced message receiving handler
  void _handleReceiveMessage(Map<String, dynamic> serverMessage) {
    final isGroupMessage = serverMessage['group'] != null;
    final chatId =
        isGroupMessage ? serverMessage['group'] : serverMessage['chat'];

    if (chatId == null) {
      return;
    }

    final newMessage = Message.fromJson(serverMessage);

    // ✅ FIX: Check if this chat is currently open
    final isCurrentChat = ChatOpenTracker.currentChatId == chatId;

    // ✅ FIX: Only set lastReadMessageId if chat is NOT currently open
    if (!isCurrentChat && lastReadMessageId[chatId] == null) {
      final existingMessages = messages[chatId] ?? [];
      if (existingMessages.isNotEmpty) {
        lastReadMessageId[chatId] = existingMessages.last.id;
      }
    }

    setState(() {
      if (messages[chatId] == null) {
        messages[chatId] = [];
      }
      messages[chatId] = [...messages[chatId]!, newMessage];
    });

    if (isCurrentChat) {
      _cleanupMessageKeys();
      if (_isUserAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        markChatAsRead(chatId, currentUserId!);
        NotificationService().clearChatNotifications(chatId);
        lastReadMessageId[chatId] = newMessage.id;
      }
    }

    // Update chat's last message and timestamp
    // _updateChatLastMessage(chatId, newMessage);

    // Force chat list to resort
    setState(() {
      if (!isGroupMessage) {
        final chatIndex = directChats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          directChats[chatIndex] = Chat(
            id: directChats[chatIndex].id,
            name: directChats[chatIndex].name,
            avatar: directChats[chatIndex].avatar,
            lastMessage: newMessage.content,
            timestamp: newMessage.timestamp,
            isGroup: directChats[chatIndex].isGroup,
            participants: directChats[chatIndex].participants,
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sortChatsSafely();
    });
  }

  Widget _buildScrollToBottomButton() {
    return AnimatedOpacity(
      opacity: _showScrollToBottom ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              //Fix scroll to bottom
              _scrollToBottom(force: true);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnreadMessageSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.greyColor.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'New messages',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.opensansRegular),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle group deletion from server
  void _handleGroupDeleted(Map<String, dynamic> data) {
    final String deletedGroupId = data['groupId'] ?? '';

    setState(() {
      groups.removeWhere((group) => group.id == deletedGroupId);

      // If the deleted group was selected, clear selection
      if (selectedChatId == deletedGroupId) {
        selectedChatId = null;
        // selectedGroup = null;
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void handleDeleteGroup() {
    if (selectedGroup == null || currentUserId == null) {
      return;
    }

    // Check if current user is the admin/owner using your existing isAdmin getter
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only group admin can delete the group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Group'),
          content: Text(
            'Are you sure you want to delete "${selectedGroup!.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performGroupDeletion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performGroupDeletion() {
    if (selectedGroup == null || currentUserId == null) return;

    _socketService.deleteGroup(
      groupId: selectedGroup?.id ?? '',
      ownerId: selectedGroup?.createdBy!.id ?? '',
      callback: (bool success) {
        if (success) {
          setState(() {
            groups.removeWhere((group) => group.id == selectedGroup!.id);
            selectedChatId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete group'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _handleGroupDetails(Map<String, dynamic> data) {
    final groupData = data['group'];

    final messagesList = data['messages'] as List;

    final transformedMessages =
        messagesList.map((msg) => Message.fromJson(msg)).toList();

    setState(() {
      messages[groupData['_id']] = transformedMessages;
    });
  }

  void _clearInputStates() {
    setState(() {
      // Ensure reply state is always cleared
      replyingToMessage = null;
      showReplyPreview = false;
      _isEditingMode = false;
      _editingMessage = null;
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
    });

    // Clear controllers
    _messageController.clear();
    _editMessageController.clear();
  }

  void _handlePrivateMessageHistory(Map<String, dynamic> data) {
    final roomId = data['roomId'];
    final messagesList = data['messages'] as List;

    final transformedMessages =
        messagesList.map((msg) => Message.fromJson(msg)).toList();

    setState(() {
      messages[roomId] = transformedMessages;
      selectedChatId = roomId;
      _isLoadingMessages = false; // Clear initial loading state
      _isLoadingOlderMessages = false; // Clear older messages loading state
      // Initialize hasMore to true since we just loaded initial messages
      _hasMoreMessages[roomId] = true;
    });
    _cleanupMessageKeys();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _fetchGroups() async {
    try {
      final fetchedGroups = await _chatService.getMyGroups();
      setState(() {
        groups = fetchedGroups.cast<GroupData>();
        for (var group in groups) {
          String groupId = group.id ?? "";
          pinnedMessagesByChat.remove(groupId); // Clear old data
        }

        // Populate pinned messages for groups
        for (var group in groups) {
          String groupId = group.id ?? '';

          if (group.pinnedMessages != null &&
              group.pinnedMessages!.isNotEmpty) {
            pinnedMessagesByChat[groupId] =
                List<dynamic>.from(group.pinnedMessages!);

            // Debug: Print each pinned message
            for (int i = 0; i < group.pinnedMessages!.length; i++) {}
          } else {
            pinnedMessagesByChat[groupId] = [];
          }
        }
      });
    } catch (e) {}
  }

  Future<void> _fetchPrivateChats() async {
    setState(() {
      _isLoadingMessages = true;
    });
    try {
      final fetchedChats =
          await _chatService.getPrivateChats(currentUserId ?? '');
      setState(() {
        directChats = fetchedChats.cast<Chat>();
        for (var chat in directChats) {
          String chatId = chat.id;

          if (chat.pinnedMessages != null && chat.pinnedMessages!.isNotEmpty) {
            pinnedMessagesByChat[chatId] =
                List<dynamic>.from(chat.pinnedMessages!);

            // Debug: Print each pinned message
            for (int i = 0; i < chat.pinnedMessages!.length; i++) {}
          } else {
            pinnedMessagesByChat[chatId] = [];
          }
        }

        _isLoadingMessages = false;
      });
    } catch (e) {}
  }

  List<Chat> get allChats {
    final unreadController = Get.find<UnreadCountController>();
    final groupUnreadController = Get.find<GroupUnreadCountController>();

    final List<Chat> combined = [
      ...directChats.map((chat) {
        final chatMessages = messages[chat.id];

        final unreadItem = unreadController.unreadCountList.firstWhere(
          (u) => u.sId == chat.id,
          orElse: () => UnreadCountModel(sId: chat.id, unreadCount: 0),
        );

        // Extract sentAt string
        final sentAtString = unreadItem.lastMessage?.sentAt;

        // Convert to DateTime safely
        late DateTime lastMessageTime;

        if (sentAtString != null) {
          lastMessageTime = DateTime.tryParse(sentAtString) ?? chat.timestamp;
        } else if (chatMessages?.isNotEmpty == true) {
          lastMessageTime = chatMessages!.last.timestamp;
        } else {
          lastMessageTime = chat.timestamp;
        }

        final unread = unreadItem.unreadCount ?? 0;

        return Chat(
          id: chat.id,
          name: chat.name,
          avatar: chat.avatar,
          lastMessage: chatMessages?.isNotEmpty == true
              ? chatMessages!.last.content
              : chat.lastMessage,
          timestamp: lastMessageTime,
          isGroup: chat.isGroup,
          participants: chat.participants,
        );
      }),
      ...groupUnreadController.unreadGroupList.map((groupUnread) {
        final groupId = groupUnread.id ?? '';

        // Use the effective timestamp from group unread controller
        final lastMessageTime = groupUnread.effectiveTimestamp;

        final unread = groupUnread.unreadCount ?? 0;

        return Chat(
          id: groupId,
          name: groupUnread.name ?? 'Unknown Group',
          avatar: groupUnread.groupAvatar ?? '/group-placeholder.jpg',
          lastMessage: groupUnread.lastMessage?.text ?? 'Group created',
          timestamp: lastMessageTime,
          // unread: unread,
          isGroup: true,
          participants: groupUnread.members
              ?.where(
                  (member) => member.userId != null) // Filter out null userIds
              .map(
                (member) => Participant(
                  id: member.userId!.id ?? '',
                  name: member.userId!.fullName.toString(),
                  avatar: member.userId!.avatar?.imageUrl,
                ),
              )
              .toList(),
        );
      }),
    ];

    // ✅ FIXED: Sort by latest message timestamp (most recent first)
    combined.sort((a, b) {
      // Primary sort: timestamp (most recent first)
      final timestampCompare = b.timestamp.compareTo(a.timestamp);
      if (timestampCompare != 0) return timestampCompare;

      // Secondary sort: unread count (higher unread first)
      // final unreadCompare = b.unread.compareTo(a.unread);
      // if (unreadCompare != 0) return unreadCompare;

      // Tertiary sort: alphabetically by name
      return a.name.compareTo(b.name);
    });

    return combined;
  }

  GroupData? get selectedGroup {
    try {
      return groups.firstWhere(
        (group) => group.id == selectedChatId,
      );
    } catch (e) {
      return null;
    }
  }

  Chat? get selectedChat {
    try {
      return allChats.firstWhere(
        (chat) => chat.id == selectedChatId,
      );
    } catch (e) {
      return null;
    }
  }

  bool get isAdmin {
    final group = selectedGroup;
    return group?.admins!.contains(currentUserId) ?? false;
  }

  // In chat_screen.dart

// ✅ UPDATE _selectChat method
  void _selectChat(String chatId) async {
    final unreadController = Get.find<UnreadCountController>();
    final groupUnreadController = Get.find<GroupUnreadCountController>();

    // ✅ Set this FIRST before any other operations
    ChatOpenTracker.currentChatId = chatId;

    final chat = allChats.firstWhereOrNull((c) => c.id == chatId);
    if (chat == null) {
      log("⚠️ Chat not found...");
      return;
    }

    _clearReplyState();

    // ✅ Clear unread counts
    if (chat.isGroup) {
      groupUnreadController.clearUnread(chatId);
    } else {
      unreadController.clearUnreadForChat(chatId);
    }

    _socketService.chatOpened(
      chatId: chatId,
      userId: currentUserId!,
      isGroup: chat.isGroup,
    );

    _socketService.markMessagesAsRead(
      chatId: chatId,
      userId: currentUserId!,
    );

    await _localFileManager.updateCurrentUserId(chatId);

    // ✅ Check if messages already loaded
    final alreadyLoaded = messages.containsKey(chatId);

    setState(() {
      selectedChatId = chatId;
      _showScrollToBottom = false;
      _translatedMessages.clear();
      _translatingMessages.clear();
      _translationError = null;
      showChatList = MediaQuery.of(context).size.width <= 600 ? false : true;
      _isLoadingMessages = !alreadyLoaded;
      _isLoadingOlderMessages = false;
      _hasShownUnreadSeparator = false;
    });

    _cleanupMessageKeys();

    try {
      _hasMoreMessages[chatId] = true;
      if (!chat.isGroup) {
        markChatAsRead(chatId, currentUserId!);
      }

      if (!alreadyLoaded) {
        setState(() => _isLoadingMessages = false);
      }
    } catch (e) {
      log("🚨 Error in _selectChat: $e");
      setState(() => _isLoadingMessages = false);
    }

    if (currentUserId != null) {
      if (chat.isGroup) {
        _joinGroup(chatId, currentUserId!, chatId);
      } else {
        if (!alreadyLoaded) {
          _joinPrivateChat(chatId);
        }
      }
    }

    // ✅ IMPROVED: Always scroll to bottom when selecting a chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sortChatsSafely();
      // Add multiple frame callbacks to ensure scroll happens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      });
    });
  }

// ✅ Add method to handle back button from chat
  void _closeChat() {
    // Prevent multiple calls
    if (selectedChatId == null) return;

    final unreadController = Get.find<UnreadCountController>();
    final groupUnreadController = Get.find<GroupUnreadCountController>();

    // Store chatId before clearing
    final String? closingChatId = selectedChatId;
    final bool isGroup = selectedChat?.isGroup ?? false;

    // ✅ Notify controllers that chat is closed
    if (isGroup) {
      groupUnreadController.closedGroup();
    } else {
      unreadController.closedChat();
    }

    // ✅ ADD THIS: Clear ChatOpenTracker
    ChatOpenTracker.currentChatId = null;

    // ✅ ADD THIS: Clear notifications for this chat
    NotificationService().clearChatNotifications(closingChatId!);

    // Clear state
    if (mounted) {
      setState(() {
        showChatList = true;
        selectedChatId = null;
        _isLoadingMessages = false;
        _isLoadingOlderMessages = false;
      });
    }
  }

  void _joinPrivateChat(String chatId) {
    //Safe chat lookup
    final chat = directChats.firstWhereOrNull((c) => c.id == chatId);

    if (chat == null) {
      log("_joinPrivateChat: chat not found for $chatId");
      return;
    }

    // Safely get the other user
    final otherParticipant =
        chat.participants?.firstWhereOrNull((p) => p.id != currentUserId);

    if (otherParticipant == null) {
      log("_joinPrivateChat: No other participant found");
      return;
    }

    //  Prevent duplicate join calls (WhatsApp-like behavior)
    if (messages.containsKey(chatId)) {
      log("🟢 Already loaded this chat ($chatId), skipping joinPrivateRoom");
      return;
    }

    if (currentUserId == null) return;

    log("📤 Joining private room with ${otherParticipant.id}");

    _socketService.joinPrivateRoom(
      currentUserId!,
      otherParticipant.id,
      (response) {
        if (response['success'] == true) {
          log(" Private room joined for chatId: $chatId");

          setState(() {
            // you don't need to store anything here
          });
        } else {
          _showSnackBar('Failed to load chat history');
        }
      },
    );
  }

  void _joinGroup(String groupId, String userId, String chatId) {
    _socketService.joinGroupRoom(groupId, userId, (success) {
      if (success) {
        setState(() {
          joinedGroups.add(groupId);
        });
        _showSnackBar('Joined group successfully');
      } else {
        _showSnackBar('Failed to join group');
      }
    });
  }

  void _handleStartPrivateChat(String user2Id) {
    if (currentUserId == null) return;

    setState(() {
      pendingPrivateChatUserId = user2Id;
      isNewPrivateChat = true;
    });

    _socketService.joinPrivateRoom(
      currentUserId!,
      user2Id,
      (response) async {
        log("🔄 joinPrivateRoom callback: $response");

        if (response['success'] == true && response['chatId'] != null) {
          final String chatId = response['chatId'];

          /// FIRST: load message history after joining
          _socketService.loadOlderPrivateMessages(
            user1Id: currentUserId!,
            user2Id: user2Id,
            onResponse: (history) {
              _handlePrivateMessageHistory(history); // manually load messages
            },
          );

          /// Refresh chat list
          await _fetchPrivateChats();

          /// Update UI
          if (mounted) {
            setState(() {
              selectedChatId = chatId;
              showChatList = false;
              showGroupInfo = false;
              selectedSection = 'direct';
              isNewPrivateChat = false;
              pendingPrivateChatUserId = null;
            });
          }
        } else {
          _showSnackBar(response['message'] ?? 'Failed to start private chat');
          setState(() {
            isNewPrivateChat = false;
            pendingPrivateChatUserId = null;
          });
        }
      },
    );
  }

  void _showMemberOptionsDialog(BuildContext context, GroupMember member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CacheImageLoader(
                    member.userId.avatar!.imageUrl,
                    ImageAssets.defaultProfileImg),
                child: member.userId.avatar?.imageUrl == null
                    ? Text(
                        member.userId.fullName.isNotEmpty
                            ? member.userId.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  member.userId.fullName,
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // ignore: unnecessary_null_comparison
                'Member since: ${member.joinedAt != null ? DateFormat.yMMMd().format(DateTime.parse(member.joinedAt)) : member.joinedAt}',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: AppFonts.opensansRegular),
              ),
              const SizedBox(height: 16),
              Text(
                'What would you like to do?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontFamily: AppFonts.opensansRegular,
                ),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     startPrivateChatWithMember(member);
            //   },
            //   style: TextButton.styleFrom(
            //     foregroundColor: Colors.blue,
            //   ),
            //   // icon: const Icon(Icons.message),
            //   child: const Text('Message'),
            // ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showReportDialog(context, member);
              },
              child: Text(
                'Report',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            if (isAdmin)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _makeUserAdmin(member);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
                child: const Text(
                  'Make Admin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }

  void _makeUserAdmin(GroupMember member) {
    if (currentUserId == null) {
      _showErrorSnackBar('Unable to identify current user');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make Admin'),
          content: Text(
              'Are you sure you want to make ${member.userId.fullName} an admin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performMakeAdmin(member);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _performMakeAdmin(GroupMember member) {
    // Show loading
    _showLoadingSnackBar('Promoting user to admin...');

    _socketService.makeAdmin(
      groupId: selectedGroup!.id ?? '', // Use currentGroupId
      userId: member.userId.id,
      ownerId: currentUserId!,
      callback: (bool success, String? message) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (success) {
          _showSnackBar(message ?? 'User made admin successfully');
        } else {
          // _showErrorDialog(message ?? 'Failed to make user admin');
        }
      },
    );
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(minutes: 1), // Long duration for loading
      ),
    );
  }

  void startPrivateChatWithMember(GroupMember member) {
    // Don't allow messaging yourself
    if (member.userId.id == currentUserId) {
      _showSnackBar('You cannot send a message to yourself');
      return;
    } else {
      otherId = member.userId.id;
    }

    // Check if there's already an existing private chat with this user
    final existingChat = directChats.firstWhere(
      (chat) => chat.participants?.any((p) => p.id == member.userId.id) == true,
      orElse: () => null as Chat,
    );

    if (existingChat != null) {
      // If chat already exists, just open it
      setState(() {
        selectedChatId = existingChat.id;
        showChatList = false;
        showGroupInfo = false;
        selectedSection = 'direct'; // Switch to direct messages tab
      });
      _showSnackBar('Opening existing chat with ${member.userId.fullName}');
    } else {
      // Start new private chat
      setState(() {
        showGroupInfo = false;
        showChatList = false;
      });

      _showSnackBar('Starting private chat with ${member.userId.fullName}...');
      _handleStartPrivateChat(member.userId.id);
    }
  }

//for
  void _showReportDialog(BuildContext context, GroupMember member) {
    _selectedReportReason = null;
    _reportDescription = '';
    _reportDescriptionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Report User',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide details about the issue you\'re reporting.',
                      style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reported User (read-only)
                    Text(
                      'Reported User',
                      style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.userId.fullName,
                        style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reason dropdown
                    Text(
                      'Reason',
                      style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReportReason,
                          hint: Text(
                            'Select a reason',
                            style: TextStyle(
                              fontFamily: AppFonts.opensansRegular,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            'spam',
                            'abuse',
                            'misleading',
                            'inappropriate',
                            'other'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontFamily: AppFonts.opensansRegular,
                                    color: AppColors.greyColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReportReason = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reportDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Please provide additional details about the report...',
                        hintStyle: TextStyle(
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        _reportDescription = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _submitReport(context, member),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Submit Report',
                    style: TextStyle(
                        fontFamily: AppFonts.opensansRegular,
                        fontWeight: FontWeight.bold,
                        color: AppColors.redColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(BuildContext context, GroupMember member) async {
    try {
      // Validation
      if (_selectedReportReason == null || _selectedReportReason!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please fill in all required fields",
              style: TextStyle(
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get token from SharedPreferences
      final UserPreferencesViewmodel userPreferences =
          UserPreferencesViewmodel();
      LoginResponseModel? userData = await userPreferences.getUser();
      SharedPreferences.getInstance();
      final token = userData!.token;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Submitting report..."),
              ],
            ),
          );
        },
      );

      // Make API call
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/report/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reportedUser': member.userId.id, // Assuming member has userId.id
          'reason': _selectedReportReason,
          'description': _reportDescription,
        }),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        Navigator.of(context).pop(); // Close report dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _selectedReportReason = null;
        _reportDescription = '';
        _reportDescriptionController.clear();
      } else {
        // Error response
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit report');
      }
    } catch (error) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      final errorMessage = error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              errorMessage.isEmpty ? "Report submission failed" : errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGroupInfo() {
    final group = selectedGroup!;
    final groupAdminName = group.members
        ?.firstWhere(
            (member) => group.admins?.contains(member.userId.id) ?? false)
        .userId
        .fullName;
    final description = group.description;
    final createdAtFormatted = DateFormat.yMMMd()
        .format(DateTime.parse(group.createdAt ?? group.updatedAt ?? ''));
    final totalMembers = group.members?.length ?? 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 20),
        // Header with back button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onPressed: () => setState(() => showGroupInfo = false),
              ),
              const SizedBox(width: 8),
              Text(
                'Group Members',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 90),
              isAdmin
                  ? IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: _showEditGroupDialog,
                    )
                  : Container(),
            ],
          ),
        ),
        // Group Info Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.blueGrey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name ?? "",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description ?? 'no description',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created At: $createdAtFormatted',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      Text(
                        'Group Admin: $groupAdminName',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      Text(
                        'Total Members: $totalMembers',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontFamily: AppFonts.opensansRegular),
                      ),
                      const SizedBox(height: 8),
                      if (isAdmin)
                        Row(
                          children: [
                            const Icon(Icons.link, size: 18),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () async {
                                if (inviteLink == null) {
                                  // Generate link first
                                  await _generateInviteLink();
                                }

                                if (inviteLink != null) {
                                  _showInviteLinkDialog();
                                }
                              },
                              child: isGeneratingLink
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Generating...',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      inviteLink == null
                                          ? 'Generate invite link'
                                          : 'Share invite link',
                                      style: TextStyle(
                                        color: AppColors.redColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        // Members list
        Expanded(
          child: ListView(
            children: groups
                .firstWhere((e) => e.id == selectedGroup!.id)
                .members!
                .map(
                  (member) => GestureDetector(
                    onTap: () => _showMemberOptionsDialog(context, member),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[300]!, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: CacheImageLoader(
                              member.userId.avatar?.imageUrl,
                              ImageAssets.defaultProfileImg,
                            ),
                            child: member.userId.avatar?.imageUrl == null
                                ? Text(
                                    member.userId.fullName.isNotEmpty
                                        ? member.userId.fullName[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 16),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.userId.fullName,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontSize: 16,
                                        fontFamily: AppFonts.opensansRegular,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (member.userId.id == currentUserId)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Me',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[800],
                                            fontFamily:
                                                AppFonts.opensansRegular,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Joined: ${DateFormat.yMMMd().format(DateTime.parse(member.joinedAt.toString()))}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";

    final parts = name.trim().split(" ");

    if (parts.length == 1) {
      // Single word → take first 2 letters
      return parts.first
          .substring(0, parts.first.length > 1 ? 2 : 1)
          .toUpperCase();
    }

    // Multiple words → first letter of first 2 words
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showEditGroupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditGroupDialog(
          groupId: selectedGroup?.id ?? '',
          currentName: selectedGroup?.name ?? '',
          currentDescription: selectedGroup!.description,
          currentAvatarUrl: selectedGroup!.groupAvatar,
          onGroupUpdated: (updatedGroup) {
            setState(() {
              final index =
                  groups.indexWhere((g) => g.id == updatedGroup['_id']);
              if (index != -1) {
                groups[index] = Group.fromJson(updatedGroup) as GroupData;
              }
            });
          },
        );
      },
    );
  }

  void _sendMessage() {
    if (selectedChatId == null ||
        _messageController.text.trim().isEmpty ||
        currentUserId == null) {
      return;
    }

    final tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final chat = selectedChat;
    final isGroup = chat?.isGroup ?? false;
    String? receiverId;

    _recentlySentMessages.add(tempMessageId);

    Timer(const Duration(seconds: 3), () {
      _recentlySentMessages.remove(tempMessageId);
      setState(() {});
    });

    if (isGroup) {
      receiverId = null;
    } else {
      if (pendingPrivateChatUserId != null) {
        receiverId = pendingPrivateChatUserId;
        otherId = receiverId ?? '';
      } else {
        final otherParticipant = chat?.participants?.firstWhere(
          (p) => p.id != currentUserId,
          orElse: () => null as Participant,
        );
        receiverId = otherParticipant?.id;
        otherId = receiverId ?? '';
      }
    }

    final messageContent = _messageController.text;
    String formattedContent = _applyFormatting(messageContent);

    // Extract mentions from the message
    final mentions = isGroup ? _extractMentionsFromText(formattedContent) : [];

    final replyToMessageId = replyingToMessage?.id;
    final isReplying = showReplyPreview && replyingToMessage != null;

    final newMessage = Message(
      id: tempMessageId,
      content: formattedContent,
      timestamp: DateTime.now(),
      sender: Sender(
        id: currentUserId!,
        name: currentUserName ?? 'Me',
        avatar: currentUserAvatar,
      ),
      isRead: false,
      replyTo: isReplying
          ? ReplyTo(
              id: replyingToMessage!.id,
              content: replyingToMessage!.content,
              sender: replyingToMessage!.sender,
            )
          : null,
      // mentions: mentions, // Add this if your Message model supports it
    );

    setState(() {
      messages[selectedChatId!] = [
        ...(messages[selectedChatId!] ?? []),
        newMessage
      ];
      _showScrollToBottom = false;
      _mentionsInMessage.clear(); // Clear mentions list
    });

    _messageController.clear();
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
      _showMentionSheet = false; // Close mention sheet
      _currentMentionQuery = '';
      _filteredMentions = [];
    });

    _cancelReply();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    log('📤 Sending message with temp ID: $tempMessageId');

    _socketService.sendMessage(
      senderId: currentUserId!,
      receiverId: isGroup ? null : receiverId,
      groupId: isGroup ? selectedChatId : null,
      content: formattedContent,
      replyToMessageId: isReplying ? replyToMessageId : null,
      mentions: mentions.map((m) => m['userId'] as String).toList(),
      callback: (response) {
        _recentlySentMessages.remove(tempMessageId);

        final success = response['success'] ?? false;
        final messageId = response['messageId'];

        if (success && messageId != null) {
          final realMessageId = messageId.toString();

          log('✅ Message sent successfully: $tempMessageId -> $realMessageId');

          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            final tempIndex =
                chatMessages.indexWhere((msg) => msg.id == tempMessageId);

            if (tempIndex != -1) {
              final updatedMessage = Message(
                id: realMessageId,
                content: chatMessages[tempIndex].content,
                timestamp: chatMessages[tempIndex].timestamp,
                sender: chatMessages[tempIndex].sender,
                isRead: chatMessages[tempIndex].isRead,
                messageType: chatMessages[tempIndex].messageType,
                replyTo: chatMessages[tempIndex].replyTo,
                reactions: chatMessages[tempIndex].reactions,
              );

              chatMessages[tempIndex] = updatedMessage;

              if (_messageKeys.containsKey(tempMessageId)) {
                final key = _messageKeys.remove(tempMessageId);
                if (key != null) {
                  _messageKeys[realMessageId] = key;
                }
              }

              messages[selectedChatId!] = List<Message>.from(chatMessages);
            }
          });

          log('✅ Message ID updated in UI: $tempMessageId -> $realMessageId');
        } else {
          log('❌ Message send failed: ${response['message']}');

          setState(() {
            final chatMessages = messages[selectedChatId!] ?? [];
            messages[selectedChatId!] =
                chatMessages.where((msg) => msg.id != tempMessageId).toList();
          });
          _showSnackBar(
              'Failed to send message: ${response['message'] ?? 'Unknown error'}');
        }
      },
    );
  }

  void _startReply(dynamic message) {
    setState(() {
      replyingToMessage =
          message is Message ? message : _convertToMessage(message);
      showReplyPreview = true;
    });
    // Focus on the text field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Message _convertToMessage(dynamic messageData) {
    if (messageData is Message) return messageData;

    // Convert from JSON/Map to Message object
    return Message(
      id: messageData['_id'] ?? messageData['id'],
      content: messageData['content'],
      timestamp: messageData['timestamp'] is DateTime
          ? messageData['timestamp']
          : DateTime.parse(
              messageData['createdAt'] ?? DateTime.now().toIso8601String()),
      sender: Sender(
        id: messageData['sender']['_id'] ?? messageData['sender']['id'],
        name:
            messageData['sender']['fullName'] ?? messageData['sender']['name'],
        avatar: messageData['sender']['avatar']?['imageUrl'],
      ),
      isRead: messageData['isRead'] ?? false,
      replyTo: messageData['replyTo'] != null
          ? ReplyTo(
              id: messageData['replyTo']['_id'] ?? messageData['replyTo']['id'],
              content: messageData['replyTo']['content'],
              sender: Sender(
                id: messageData['replyTo']['sender']['_id'] ??
                    messageData['replyTo']['sender']['id'],
                name: messageData['replyTo']['sender']['fullName'] ??
                    messageData['replyTo']['sender']['name'],
                avatar: messageData['replyTo']['sender']['avatar']?['imageUrl'],
              ),
            )
          : null,
    );
  }

// Add method to cancel reply
  void _cancelReply() {
    setState(() {
      replyingToMessage = null;
      showReplyPreview = false;
    });
    // Also clear any formatting states to ensure clean state
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
    });
  }

  String _applyFormatting(String text) {
    String formattedText = text;

    if (_isBold) {
      formattedText = '*$formattedText*';
    }
    if (_isItalic) {
      formattedText = '_${formattedText}_';
    }
    if (_isUnderline) {
      formattedText = '~$formattedText~';
    }

    return formattedText;
  }

// Add this function to handle starting direct chat with a user from community search
  // FIXED: Add this function to handle starting direct chat with a user from community search
  void _startDirectChatWithUser(User user) {
    // Don't allow messaging yourself
    if (user.id == currentUserId) {
      _showSnackBar('You cannot send a message to yourself');
      return;
    }

    otherId = user.id;
    // Check if there's already an existing private chat with this user
    Chat? existingChat;
    try {
      // Use where().firstOrNull or where().isEmpty to safely check
      final matchingChats = directChats.where(
        (chat) => chat.participants?.any((p) => p.id == user.id) == true,
      );

      existingChat = matchingChats.isNotEmpty ? matchingChats.first : null;
    } catch (e) {
      // No existing chat found
      existingChat = null;
    }

    if (existingChat != null) {
      // If chat already exists, select it
      setState(() {
        selectedChatId = existingChat!.id;
        showChatList = false;
        showGroupInfo = false;
        selectedSection = 'direct';
      });
      _showSnackBar('Opening existing chat with ${user.fullName}');
    } else {
      // No existing chat found, start new private chat using your existing function
      setState(() {
        showChatList = false;
        showGroupInfo = false;
        selectedSection = 'direct';
      });

      _showSnackBar('Starting new chat with ${user.fullName}...');
      _handleStartPrivateChat(user.id); // Use your existing function
    }
  }

  Future<void> _handleGroupCreation() async {
    // Validate group creation limit before proceeding
    bool canCreateGroup = await _validateGroupCreationLimit();

    if (!canCreateGroup) {
      return; // Stop group creation if limit is reached
    }

    // Proceed with group creation if within limit
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupManagementScreen(
          onJoinGroup: _showJoinGroupDialog,
        ),
      ),
    );
  }

  void _scrollToBottom({bool force = false, bool isInitialLoad = false}) {
    if (!_scrollController.hasClients) {
      // Schedule scroll for next frame if controller not ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(force: force, isInitialLoad: isInitialLoad);
      });
      return;
    }

    if (isInitialLoad || force) {
      // For initial load or forced scroll, use multiple frame callbacks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      });
    } else {
      // For regular scrolling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(dynamic timestamp) {
    try {
      DateTime dateTime;

      // Handle different timestamp formats
      if (timestamp is String) {
        // Parse ISO 8601 string (like "2025-06-17T07:23:14.190Z")
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is int) {
        // Handle milliseconds since epoch
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return 'Invalid time';
      }

      // Convert to local time
      dateTime = dateTime.toLocal();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      // Format time part
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');
      String timeString = '$hour:$minute';

      // Check if message is from today
      if (messageDate == today) {
        return timeString;
      }

      // Check if message is from yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      if (messageDate == yesterday) {
        return 'Yesterday $timeString';
      }

      // Check if message is from this week
      final weekAgo = today.subtract(const Duration(days: 7));
      if (messageDate.isAfter(weekAgo)) {
        return '${_getDayName(dateTime.weekday)} $timeString';
      }

      // Check if message is from this year
      if (dateTime.year == now.year) {
        return '${dateTime.day} ${_getMonthName(dateTime.month)} $timeString';
      }

      // Message is from previous year
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year} $timeString';
    } catch (e) {
      return 'Invalid time';
    }
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.greyColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        cursorHeight: 20,
        cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search here..',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: AppFonts.opensansRegular,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        )),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: _initializeChat,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: selectedChatId == null
          ? AppBar(
              automaticallyImplyLeading: true,
              title: Text(
                'Chat',
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              // foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              actions: [
                IconButton(
                  onPressed: () {
                    _showStarredMessagesPopup(context);
                  },
                  // This includes validation
                  icon: Icon(
                    Icons.star,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  tooltip: 'Starred Message',
                ),
                IconButton(
                  onPressed: () =>
                      _handleGroupCreation(), // This includes validation
                  icon: Icon(
                    Icons.people,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  tooltip: 'Create Group',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showCommunityMembers = !showCommunityMembers;
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                )
              ],
            )
          : null,
      body: Stack(children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Builder(builder: (context) {
            if (showGroupInfo && selectedGroup != null) {
              return _buildGroupInfo();
            }
            // Show community members widget when needed
            if (showCommunityMembers) {
              return CommunityMembersWidget(
                onUserSelected: (User user) {
                  _startDirectChatWithUser(user);

                  // Hide the community members widget
                  setState(() {
                    showCommunityMembers = false;
                  });
                },
                onClose: () {
                  setState(() {
                    showCommunityMembers = false;
                  });
                },
              );
            }

            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                children: [
                  // Chat List Panel
                  if (showChatList || MediaQuery.of(context).size.width > 600)
                    Container(
                      width: MediaQuery.of(context).size.width > 600
                          ? 350
                          : MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(color: Colors.grey, width: 0.5)),
                      ),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          // _buildSectionTabs(),
                          Expanded(child: _buildChatList()),
                        ],
                      ),
                    ),

                  // Chat Messages Panel
                  if (selectedChatId != null &&
                      (!showChatList ||
                          MediaQuery.of(context).size.width > 600))
                    Expanded(child: _buildChatMessages()),
                ],
              ),
            );
          }),
        ),
        if (_showForwardDialog) _buildForwardDialog(),
      ]),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      padding: const EdgeInsets.only(right: 15, left: 15, bottom: 5),
      child: Row(
        children: [
          _buildTab('All', 'all'),
          SizedBox(width: 4),
          _buildTab('Direct', 'direct'),
          SizedBox(width: 4),
          _buildTab('Circles', 'groups'),
        ],
      ),
    );
  }

  Widget _buildTab(String title, String section) {
    final isSelected = selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSection = section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textfieldColor
                : AppColors.loginContainerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    Get.find<UnreadCountController>();
    Get.find<GroupUnreadCountController>();

    return Obx(() {
      List<Chat> filteredChats = allChats;
      // SECTION FILTER
      switch (selectedSection) {
        case 'direct':
          filteredChats = filteredChats.where((chat) => !chat.isGroup).toList();
          break;
        case 'groups':
          filteredChats = filteredChats.where((chat) => chat.isGroup).toList();
          break;
      }

      // SEARCH FILTER
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        filteredChats = filteredChats
            .where((chat) => chat.name.toLowerCase().contains(query))
            .toList();
      }

      // NO RESULTS
      if (filteredChats.isEmpty && _searchController.text.isNotEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No chats found',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: AppFonts.opensansRegular,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.opensansRegular,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshChatList,
        color: Colors.blueAccent,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            return _buildChatListItem(chat);
          },
        ),
      );
    });
  }

  Widget _buildChatListItem(Chat chat) {
    final unreadController = Get.find<UnreadCountController>();
    final groupUnreadController = Get.find<GroupUnreadCountController>();

    return Obx(() {
      int unreadCount = 0;
      DateTime? lastTime;

      if (chat.isGroup) {
        final groupUnreadItem =
            groupUnreadController.unreadGroupList.firstWhere(
          (g) => g.id == chat.id,
          orElse: () => GroupUnreadCountModel(id: chat.id, unreadCount: 0),
        );

        unreadCount = groupUnreadItem.unreadCount;

        lastTime = groupUnreadItem.effectiveTimestamp;
      } else {
        // PRIVATE CHAT
        final unreadItem = unreadController.unreadCountList.firstWhere(
          (u) => u.sId == chat.id,
          orElse: () => UnreadCountModel(sId: chat.id, unreadCount: 0),
        );

        unreadCount = unreadItem.unreadCount ?? 0;

        final sentAtString = unreadItem.lastMessage?.sentAt;

        if (sentAtString != null) {
          lastTime = DateTime.tryParse(sentAtString);
        }

        lastTime ??= chat.timestamp;
      }

      final formattedTime = _formatTime(lastTime);

      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onLongPress: () => _showDeleteConfirmationDialog(chat),
        onTap: () => _selectChat(chat.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            children: [
              _buildChatAvatar(chat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _buildLastMessageSubtitle(chat),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //  FIXED TIME DISPLAY
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      color: unreadCount > 0 ? Colors.blue : Colors.grey,
                    ),
                  ),

                  if (unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$unreadCount",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatAvatar(Chat chat) {
    final imageUrl = chat.avatar?.trim();
    final initials = _getInitials(chat.name);

    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.greyColor,
      backgroundImage: hasImage ? CachedNetworkImageProvider(imageUrl) : null,
      child: !hasImage
          ? Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  void _showDeleteConfirmationDialog(Chat chat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Delete Chat"),
          content:
              Text("Are you sure you want to delete chat with ${chat.name}?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();

                // Create controller instance
                final ChatController controller = Get.put(ChatController());

                // Build request body
                final body = {
                  "chatType": chat.isGroup == true ? "group" : "private",
                  "chatId": chat.id,
                };

                // Call delete API
                await controller.deleteChat(body);

                // Optionally remove chat from local list or refresh UI
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLastMessageSubtitle(Chat chat) {
    final chatMessages = messages[chat.id];

    final dynamic localLastMessage =
        (chatMessages?.isNotEmpty == true) ? chatMessages!.last : null;

    final dynamic serverLastMessage = chat.lastMessage;

    // Determine which message to use
    final dynamic messageData =
        (localLastMessage != null) ? localLastMessage : serverLastMessage;

    String messageText = '';

    if (messageData != null) {
      // Check if it's a Message object (from local messages)
      if (messageData is Message) {
        final messageType = messageData.messageType ?? 'text';

        if (messageType == 'sticker') {
          messageText = '📷 Sent sticker';
        } else if (messageType == 'video') {
          messageText = '🎥 Sent Video';
        } else if (messageType == 'audio') {
          messageText = '🎤Sent Audio';
        } else if (messageType == 'file') {
          messageText = '📎 Sent File';
        } else {
          messageText = messageData.content;
        }
      }
      // Check if it's a Map (from server/chat object)
      else if (messageData is Map<String, dynamic>) {
        final messageType = messageData['messageType'];

        if (messageType == 'sticker') {
          messageText = '📷 Sticker';
        } else if (messageType == 'video') {
          messageText = '🎥 Video';
        } else if (messageType == 'audio') {
          messageText = '🎤 Audio';
        } else if (messageType == 'file') {
          messageText = '📎 File';
        } else {
          // Default to text content
          messageText = (messageData['text'] ??
                  messageData['content'] ??
                  messageData['message'] ??
                  '')
              .toString();
        }
      }
      // Check if it's a plain string
      else if (messageData is String) {
        messageText = messageData;
      }
      // Fallback for other types
      else {
        try {
          messageText = messageData.toString();
        } catch (_) {
          messageText = 'Unsupported message type';
        }
      }
    }

    // Check for reply icon
    bool hasReply = false;
    if (localLastMessage != null) {
      if (localLastMessage is Message) {
        hasReply = localLastMessage.replyTo != null;
      } else {
        try {
          final dynamic dyn = localLastMessage as dynamic;
          hasReply = dyn.replyTo != null;
        } catch (_) {
          hasReply = false;
        }
      }
    } else if (serverLastMessage is Map<String, dynamic>) {
      hasReply = serverLastMessage['replyTo'] != null;
    }

    // Check for reaction count
    int reactionCount = 0;
    if (localLastMessage != null) {
      if (localLastMessage is Message) {
        reactionCount = localLastMessage.reactions?.length ?? 0;
      } else {
        try {
          final dynamic dyn = localLastMessage as dynamic;
          final dynamic reactions = dyn.reactions;
          if (reactions is List) reactionCount = reactions.length;
        } catch (_) {
          reactionCount = 0;
        }
      }
    } else if (serverLastMessage is Map<String, dynamic>) {
      final dynamic reactions = serverLastMessage['reactions'];
      if (reactions is List) reactionCount = reactions.length;
    }

    final List<Widget> subtitleWidgets = [];

    // Add reply icon if message is a reply
    if (hasReply) {
      subtitleWidgets
          .add(const Icon(Icons.reply, size: 14, color: Colors.grey));
      subtitleWidgets.add(const SizedBox(width: 4));
    }

    // Add message text (without sender name)
    subtitleWidgets.add(
      Expanded(
        child: Text(
          messageText.isEmpty ? '' : messageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: messageText.isEmpty ? Colors.grey : AppColors.textColor,
            fontFamily: AppFonts.opensansRegular,
            fontSize: 14,
          ),
        ),
      ),
    );
    return Row(children: subtitleWidgets);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 1. Edit-preview
          if (_isEditingMode && _editingMessage != null) _buildEditPreview(),

          // 3. Reply-preview
          if (!_isEditingMode && showReplyPreview && replyingToMessage != null)
            _buildReplyPreview(),

          // 4. Uploading indicator
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const Text('Uploading file…', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: _uploadProgress),
                ],
              ),
            ),

          // 5. Formatting toolbar
          // _buildFormattingToolbar(),
          const SizedBox(height: 4),
          // 6. Input row
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildEditPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _editingMessage!.content,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.blue.shade700),
            onPressed: _cancelEditing,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.reply, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyingToMessage!.sender.name}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontFamily: AppFonts.opensansRegular),
                ),
                const SizedBox(height: 2),
                _buildReplyPreviews(replyingToMessage!),
              ],
            ),
          ),
          IconButton(
            onPressed: _cancelReply,
            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreviews(Message msg) {
    final url = msg.content.toLowerCase();

    // Detect file types
    final isImage = url.endsWith(".png") ||
        url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".gif");
    final isVideo =
        url.endsWith(".mp4") || url.endsWith(".mov") || url.endsWith(".mkv");
    final isAudio =
        url.endsWith(".mp3") || url.endsWith(".aac") || url.endsWith(".wav");

    switch (msg.messageType) {
      case "text":
        return Text(
          msg.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );

      case "image":
      case "sticker":
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            msg.content,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        );

      case "file":
        if (isImage) {
          // file but image
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              msg.content,
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
          );
        } else if (isVideo) {
          // file but video
          return Row(
            children: const [
              Icon(Icons.videocam, size: 18, color: Colors.grey),
              SizedBox(width: 5),
              Text("Video", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          );
        } else if (isAudio) {
          // file but audio
          return Row(
            children: const [
              Icon(Icons.audiotrack, size: 18, color: Colors.grey),
              SizedBox(width: 5),
              Text("Audio", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          );
        } else {
          // unknown file
          return Row(
            children: const [
              Icon(Icons.insert_drive_file, size: 18, color: Colors.grey),
              SizedBox(width: 5),
              Text("File", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          );
        }

      case "audio":
        return Row(
          children: const [
            Icon(Icons.audiotrack, size: 18, color: Colors.grey),
            SizedBox(width: 5),
            Text("Audio", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        );

      case "video":
        return Row(
          children: const [
            Icon(Icons.videocam, size: 18, color: Colors.grey),
            SizedBox(width: 5),
            Text("Video", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        );

      default:
        return Text(
          msg.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
    }
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: Colors.blue,
            onPressed: _isUploading ? null : _handleFileUpload,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            color: Colors.blue,
            tooltip: 'Select Sticker',
            onPressed: _showStickerSelector,
          ),
          // Replace the Expanded TextField in _buildInputRow (around line 3800) with:
          Expanded(
            child: TextField(
              controller:
                  _isEditingMode ? _editMessageController : _messageController,
              decoration: InputDecoration(
                hintText: _isEditingMode
                    ? 'Edit message…'
                    : (showReplyPreview ? 'Reply…' : 'Type a message…'),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              maxLines: null,
              onChanged: isGroup
                  ? _onMessageTextChanged
                  : null, // Add mention detection for groups
              onSubmitted: (_) {
                if (_isEditingMode) {
                  _saveEditedMessage();
                } else {
                  _sendMessage();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(_isEditingMode ? Icons.check : Icons.send),
            onPressed: _isEditingMode ? _saveEditedMessage : _sendMessage,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  // Show message options (reply, copy, etc.)
  // Widget _buildFormattingToolbar() {
  //   return SizedBox(
  //     height: 30,
  //     child: Row(
  //       children: [
  //         Text(
  //           'Format: ',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(width: 8),

  //         // Bold button
  //         _buildFormatButton(
  //           icon: Icons.format_bold,
  //           isActive: _isBold,
  //           onPressed: () => setState(() => _isBold = !_isBold),
  //           tooltip: 'Bold',
  //         ),

  //         // Italic button
  //         _buildFormatButton(
  //           icon: Icons.format_italic,
  //           isActive: _isItalic,
  //           onPressed: () => setState(() => _isItalic = !_isItalic),
  //           tooltip: 'Italic',
  //         ),

  //         // Underline button
  //         _buildFormatButton(
  //           icon: Icons.format_underline,
  //           isActive: _isUnderline,
  //           onPressed: () => setState(() => _isUnderline = !_isUnderline),
  //           tooltip: 'Underline',
  //         ),

  //         const SizedBox(width: 16),

  //         // Clear formatting button
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               _isBold = false;
  //               _isItalic = false;
  //               _isUnderline = false;
  //             });
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //             decoration: BoxDecoration(
  //               color: Colors.grey[200],
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //             child: Text(
  //               'Clear',
  //               style: TextStyle(
  //                 fontSize: 11,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey[300]!,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Number of shimmer items to show
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Message content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 60,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatMessages() {
    final unreadController = Get.find<UnreadCountController>();

    final unreadChat = unreadController.unreadCountList
        .firstWhereOrNull((e) => e.sId == selectedChatId);

    final myId = currentUserId;

    Participants? otherUser;
    if (unreadChat?.participants != null) {
      otherUser =
          unreadChat!.participants!.firstWhereOrNull((p) => p.id != myId);
    }

    final status = otherUser?.status;

    String formatLastSeen(String? isoTime) {
      if (isoTime == null) return "Not active";

      final date = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();

      // Format time part → 10:20 AM
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = date.hour >= 12 ? "PM" : "AM";
      final timeFormatted = "$hour:$minute $ampm";

      // Same day → "Last seen today at 10 AM"
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return "today at $timeFormatted";
      }

      // Yesterday → "Last seen yesterday at 9 PM"
      final yesterday = now.subtract(const Duration(days: 1));
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return " yesterday at $timeFormatted";
      }

      // Other days → "Last seen on 12 Jan at 8 PM"
      final monthNames = [
        "",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];

      final day = date.day;
      final month = monthNames[date.month];

      return "on $day $month at $timeFormatted";
    }

    if (selectedChatId == null || selectedChat == null) {
      return const SizedBox.shrink();
    }

    final chatMessages = messages[selectedChatId] ?? [];
    final chat = selectedChat;
    final isLoading = _isLoadingMessages;
    final pinnedMessagesForChat = currentChatPinnedMessages;

    final displayMessages = _isChatSearching && _chatSearchQuery.isNotEmpty
        ? _chatFilteredMessages
        : chatMessages;

    if (selectedChatId != null &&
        lastReadMessageId[selectedChatId!] == null &&
        displayMessages.length > 1) {
      final testLastReadId =
          _getMessageId(displayMessages[displayMessages.length - 2]);
      lastReadMessageId[selectedChatId!] = testLastReadId;
    }

    isGroup = chat?.isGroup ?? false;
    return Stack(
      children: [
        Column(
          children: [
            // Chat Header (keep existing)
            Container(
              padding:
                  const EdgeInsets.only(top: 32, bottom: 2, left: 8, right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.textfieldColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width <= 600)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        _clearReplyState();
                        _closeChat();
                        // setState(() {
                        //   showChatList = true;
                        //   selectedChatId = null;
                        // });
                      },
                    ),
                  InkWell(
                    onTap: () {
                      final chatProfile = ChatProfile(
                          userId: otherId,
                          name: chat.name,
                          profileImageUrl: chat.avatar ?? '',
                          username: chat.name);
                      Get.toNamed(RouteName.chatProfileScreen,
                          arguments: chatProfile);
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.greyColor,
                      backgroundImage: (chat!.avatar != null &&
                              chat.avatar!.trim().isNotEmpty)
                          ? CachedNetworkImageProvider(chat.avatar!)
                          : null,
                      child:
                          (chat.avatar == null || chat.avatar!.trim().isEmpty)
                              ? Text(
                                  _getInitials(chat.name),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isChatSearching
                        ? _buildChatSearchBar()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.name,
                                style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              if (chat.isGroup != true)
                                Text(
                                  status?.isOnline == true
                                      ? "Online"
                                      : "Last seen ${formatLastSeen(status?.lastSeen)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: status?.isOnline == true
                                        ? Colors.green
                                        : AppColors.greyColor,
                                    fontFamily: AppFonts.opensansRegular,
                                  ),
                                ),
                              if (chat.isGroup == true)
                                Text(
                                  '${chat.participants?.length ?? 0} members',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppFonts.opensansRegular,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                            ],
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isChatSearching ? Icons.close : Icons.search,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _isChatSearching = !_isChatSearching;
                        if (!_isChatSearching) {
                          _chatSearchQuery = '';
                          _chatSearchController.clear();
                          _chatFilteredMessages.clear();
                        }
                      });
                    },
                  ),
                  if (chat.isGroup == true && !_isChatSearching)
                    PopupMenuButton<String>(
                      iconColor: Theme.of(context).textTheme.bodyLarge?.color,
                      onSelected: _handleGroupMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'info',
                            child: Text(
                              'Group Info',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular),
                            )),
                        if (isAdmin) ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit Group',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Group',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular),
                            ),
                          ),
                        ],
                        PopupMenuItem(
                            value: 'leave',
                            child: Text(
                              'Leave Group',
                              style: TextStyle(
                                  fontFamily: AppFonts.opensansRegular),
                            )),
                      ],
                    ),
                ],
              ),
            ),

            // Search Results
            if (_isChatSearching && _chatSearchQuery.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${_chatFilteredMessages.length} message${_chatFilteredMessages.length != 1 ? 's' : ''} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: AppFonts.opensansRegular,
                      ),
                    ),
                    const Spacer(),
                    if (_chatFilteredMessages.isNotEmpty)
                      TextButton(
                        onPressed: _clearChatSearch,
                        child: Text(
                          'Clear',
                          style: TextStyle(
                              color: AppColors.redColor,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                      ),
                  ],
                ),
              ),

            // Pinned Messages
            if (pinnedMessagesForChat.isNotEmpty && !_isChatSearching)
              _buildPinnedMessagesSection(pinnedMessagesForChat),

            // Messages List with Enhanced Background
            Expanded(
              child: Stack(
                children: [
                  // SimpleGradientBackground(),
                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: _buildShimmerLoading(),
                    )
                  else if (displayMessages.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        EncryptionNotice(),
                        _buildChatEmptyState(),
                      ],
                    )
                  else
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: displayMessages.length + 1,
                      itemBuilder: (context, index) {
                        //  SHOW ENCRYPTION NOTICE as first item
                        if (index == 0) {
                          return EncryptionNotice();
                        }

                        // Adjust index for actual messages
                        final messageIndex = index - 1;
                        final message = displayMessages[messageIndex];
                        final isMe = message.sender.id == currentUserId;
                        if (!isMe) otherId = message.sender.id;

                        final showDateSeparator = messageIndex == 0 ||
                            !_isSameDay(message.timestamp,
                                displayMessages[messageIndex - 1].timestamp);

                        bool showUnreadSeparator = false;
                        if (!_isChatSearching &&
                            !_hasShownUnreadSeparator &&
                            selectedChatId != null) {
                          String? lastReadId =
                              lastReadMessageId[selectedChatId!];
                          if (lastReadId != null && lastReadId.isNotEmpty) {
                            if (messageIndex > 0) {
                              final previousMessage =
                                  displayMessages[messageIndex - 1];
                              final previousMessageId =
                                  _getMessageId(previousMessage);
                              if (previousMessageId == lastReadId &&
                                  ((previousMessage.isRead ||
                                          previousMessage.isEdited ||
                                          previousMessage.isForwarded) ==
                                      false)) {
                                showUnreadSeparator = true;
                                _hasShownUnreadSeparator = true;
                              }
                            }
                          }
                        }

                        return Column(
                          children: [
                            if (showDateSeparator)
                              _buildDateSeparator(message.timestamp),
                            if (showUnreadSeparator)
                              _buildUnreadMessageSeparator(),
                            _buildMessageBubbleWithLongPress(message, isMe,
                                highlightSearch: _isChatSearching),
                          ],
                        );
                      },
                    ),

                  if (_isLoadingOlderMessages)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (!_isChatSearching) _buildMessageInput(),
          ],
        ),
        if (_showScrollToBottom && !_isChatSearching)
          Positioned(
            bottom: 100,
            right: 16,
            child: _buildScrollToBottomButton(),
          ),
        if (_showMentionSheet && isGroup) _buildMentionSheet(),
      ],
    );
  }

// Chat search bar widget
  Widget _buildChatSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        cursorHeight: 20,
        cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
        controller: _chatSearchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onChanged: _onChatSearchChanged,
        style: TextStyle(
          fontFamily: AppFonts.opensansRegular,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

// Chat search functionality
  void _onChatSearchChanged(String query) {
    setState(() {
      _chatSearchQuery = query.toLowerCase();
      if (_chatSearchQuery.isEmpty) {
        _chatFilteredMessages.clear();
      } else {
        final chatMessages = messages[selectedChatId] ?? [];
        _chatFilteredMessages = chatMessages.where((message) {
          return message.content.toLowerCase().contains(_chatSearchQuery) ||
              message.sender.name.toLowerCase().contains(_chatSearchQuery);
        }).toList();
      }
    });
  }

  void _clearChatSearch() {
    setState(() {
      _chatSearchQuery = '';
      _chatSearchController.clear();
      _chatFilteredMessages.clear();
    });
  }

// Chat empty state widget
  Widget _buildChatEmptyState() {
    if (_isChatSearching && _chatSearchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

// Updated Pinned Messages Section Widget to accept specific pinned messages
  Widget _buildPinnedMessagesSection(List<dynamic> pinnedMessagesForChat) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          itemCount: pinnedMessagesForChat.length,
          itemBuilder: (context, index) {
            final message = pinnedMessagesForChat[index];
            return _buildPinnedMessageCard(message);
          },
        ),
      ),
    );
  }

  Widget _buildPinnedMessageCard(dynamic message) {
    return GestureDetector(
      onTap: () => _scrollToMessage(message),
      onLongPress: () => _unpinMessage(message),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: _buildPinnedMessageContent(message),
      ),
    );
  }

  Widget _buildPinnedMessageContent(dynamic message) {
    try {
      String? content;
      String? messageType;
      String? fileName;

      if (message is Map<String, dynamic>) {
        content = message['content']?.toString();
        messageType =
            message['messageType']?.toString() ?? message['type']?.toString();
        fileName = message['fileName']?.toString();
      } else {
        content = message.content?.toString();
        messageType = message.messageType?.toString();
        fileName = message.fileInfo?.name?.toString();
      }

      messageType = messageType?.toLowerCase() ?? "";

      // FORCE detect type by extension also
      if (content != null) {
        if (content.contains(".jpg") ||
            content.contains(".jpeg") ||
            content.contains(".png") ||
            messageType.contains("image")) {
          messageType = "image";
        } else if (content.contains(".mp4") ||
            content.contains(".mov") ||
            messageType.contains("video")) {
          messageType = "video";
        } else if (content.contains(".mp3") ||
            content.contains(".wav") ||
            messageType.contains("audio")) {
          messageType = "audio";
        } else if (messageType.contains("application") ||
            messageType.contains("file") ||
            messageType.contains("document")) {
          messageType = "file";
        }
      }

      switch (messageType) {
        case 'image':
          return _iconLabelCard(Icons.image, "Photo");

        case 'video':
          return _iconLabelCard(Icons.videocam, "Video");

        case 'audio':
          return _iconLabelCard(Icons.audiotrack, "Audio");

        case 'file':
          String ext = "";
          if (fileName != null && fileName.contains(".")) {
            ext = fileName.split(".").last.toUpperCase();
          }
          return _iconLabelCard(
              Icons.insert_drive_file, ext.isEmpty ? "Document" : "$ext File");

        default:
          return _textCard(content ?? "Message");
      }
    } catch (e) {
      return _textCard("Message");
    }
  }

  Widget _iconLabelCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.opensansRegular),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  Widget _textCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.opensansRegular),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Improved _getMessageId method with better error handling
  String? _getMessageId(dynamic message) {
    try {
      if (message == null) {
        return null;
      }

      if (message is Message) {
        return message.id;
      } else if (message is Map<String, dynamic>) {
        final id = message['_id'] ?? message['id'];

        return id?.toString();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _scrollToMessage(dynamic pinnedMessage) async {
    if (pinnedMessage == null) {
      _showErrorSnackBar('Invalid pinned message');
      return;
    }

    String? messageId = _getMessageId(pinnedMessage);

    if (messageId == null || messageId.isEmpty) {
      _showErrorSnackBar('Invalid pinned message ID');
      return;
    }

    // Wait for the next frame to ensure the list is built
    await Future.delayed(const Duration(milliseconds: 100));

    final chatMessages = messages[selectedChatId] ?? [];

    // Find the message index in the list
    int messageIndex = -1;
    for (int i = 0; i < chatMessages.length; i++) {
      if (_getMessageId(chatMessages[i]) == messageId) {
        messageIndex = i;
        break;
      }
    }

    if (messageIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message not found in current chat'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Set the highlighted message
    setState(() {
      _highlightedMessageId = messageId;
    });

    // Wait for the UI to update and keys to be assigned
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try multiple approaches to ensure the message is scrolled to

      // Approach 1: Use ListView's scroll controller
      if (_scrollController.hasClients) {
        final itemHeight = 100.0; // Approximate height of each message
        final targetOffset = (messageIndex * itemHeight).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // Approach 2: Use GlobalKey if available (backup)
      final key = _messageKeys[messageId];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }

      // Remove highlight after 3 seconds
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _highlightedMessageId = null;
          });
        }
      });
    });
  }

  Widget _buildMessageBubbleWithLongPress(Message message, bool isMe,
      {bool highlightSearch = false}) {
    final messageId = message.id.toString();
    final isHighlighted = _highlightedMessageId == messageId;
    final isSending = messageId.startsWith('temp-') ||
        _recentlySentMessages.contains(messageId);

    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }

    final key = _messageKeys[messageId];

    return Stack(children: [
      Dismissible(
        key: Key(message.id),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          _startReply(message);
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(
            Icons.reply,
            color: Colors.blue,
            size: 24,
          ),
        ),
        child: GestureDetector(
          onLongPress:
              isSending ? null : () => _showMessageOptions(message, isMe),
          child: Opacity(
            opacity: isSending ? 0.7 : 1.0, // ✅ Visual feedback for sending
            child: Container(
              key: key,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.yellow.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: isHighlighted
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                    : EdgeInsets.zero,
                child: _buildMessageBubble(message, isMe),
              ),
            ),
          ),
        ),
      ),
      if (isSending && isMe)
        Positioned(
            left: MediaQuery.of(context).size.width * 0.87,
            bottom: MediaQuery.of(context).size.height * 0.01,
            child: Icon(
              Icons.watch_later_outlined,
              color: Colors.grey,
              size: 10,
            )),
    ]);
  }

  void _cleanupMessageKeys() {
    if (selectedChatId == null) return;

    final currentMessageIds = messages[selectedChatId]
            ?.map((msg) => _getMessageId(msg))
            .where((id) => id != null)
            .toSet() ??
        <String>{};

    // Remove keys for messages that are no longer in the current chat
    _messageKeys.keys
        .where((key) => !currentMessageIds.contains(key))
        .toList()
        .forEach(_messageKeys.remove);
  }

  void _showMessageOptions(dynamic message, bool isMe) {
    if (selectedChatId == null || message == null) return;

    String? messageId = _getMessageId(message);
    if (messageId!.isEmpty) {
      _showErrorSnackBar('Invalid message');
      return;
    }

    List<dynamic> currentPinned = currentChatPinnedMessages;
    final isPinned = currentPinned
        .where((m) => m != null && _getMessageId(m) == messageId)
        .isNotEmpty;

    // Check if message is translated
    final isTranslated = _translatedMessages.containsKey(messageId);
    final isTranslating = _translatingMessages.contains(messageId);

    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add translation option for received messages only
            if (!isMe && message.messageType == 'text') ...[
              ListTile(
                leading: isTranslating
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.blue,
                          ),
                        ),
                      )
                    : Icon(
                        isTranslated
                            ? Icons.translate_outlined
                            : Icons.translate,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                title: Text(
                  isTranslating
                      ? 'Translating...'
                      : (isTranslated ? 'Show Original' : 'Translate'),
                  style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                onTap: isTranslating
                    ? null
                    : () {
                        Navigator.pop(context);
                        _translateMessage(message);
                      },
              ),
              Divider(color: Colors.grey.shade300),
            ],

            ListTile(
              leading: Icon(
                Icons.add_reaction,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              title: Text(
                'React',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEmojiReactions(messageId);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.forward,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              title: Text(
                'Forward',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              // onTap: () {
              //   Navigator.pop(context);
              //   _showForwardMessageDialog(message);
              // },

              onTap: () {
                Navigator.pop(context);

                if (message is Message) {
                  _showForwardMessageDialog(message);
                } else {
                  _showForwardMessageDialog(_convertToMessage(message));
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.star,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              title: Text(
                'Important',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              onTap: () async {
                _starMessage(message);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              title: Text(
                isPinned ? 'Unpin Message' : 'Pin Message',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                if (isPinned) {
                  _unpinMessage(message);
                } else {
                  _pinMessage(message);
                }
              },
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(
                  'Edit',
                  style: TextStyle(
                      fontFamily: AppFonts.opensansRegular,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _startEditingMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            ],
            ListTile(
              leading: Icon(
                Icons.copy,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              title: Text(
                'Copy',
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
          ],
        ),
      ),
    );
  }

// Updated copy message function
  void _copyMessage(dynamic message) {
    try {
      String? content;
      String? messageType;

      if (message is Map<String, dynamic>) {
        content = message['content']?.toString();
        messageType =
            message['messageType']?.toString() ?? message['type']?.toString();
      } else {
        content = message.content?.toString();
        messageType =
            message.messageType?.toString() ?? message.type?.toString();
      }

      if (messageType == 'text' && content != null) {
        Clipboard.setData(ClipboardData(text: content));
        _showSuccessSnackBar('Message copied to clipboard');
      } else {
        _showErrorSnackBar('Cannot copy this message type');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to copy message');
    }
  }

  void _handleGroupMenuAction(String action) {
    switch (action) {
      case 'info':
        setState(() => showGroupInfo = true);
        break;
      case 'edit':
        _editGroup();
        break;
      case 'delete':
        _showDeleteGroupDialog();
        break;
      case 'leave':
        _showLeaveGroupDialog();
        break;
    }
  }

  void _editGroup() {
    _showSnackBar('Group edited successfully');
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
            'Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              handleDeleteGroup();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _leaveGroup();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _leaveGroup() {
    final group = selectedGroup;
    if (group == null || currentUserId == null) return;

    _socketService.leaveGroup(
      group.id ?? "",
      currentUserId!,
      (success) {
        if (success) {
          setState(() {
            groups.removeWhere((g) => g.id == group.id);
            selectedChatId = null;
          });
          _showSnackBar('Left group successfully');
        } else {
          _showSnackBar('Failed to leave group');
        }
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        _formatDateSeparator(date),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }
}
