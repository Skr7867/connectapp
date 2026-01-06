import 'dart:convert';
import 'dart:io';

import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../data/response/status.dart';
import '../../models/UserLogin/user_login_model.dart';
import '../../models/UserProfile/user_profile_media_list_model.dart';
import '../../res/api_urls/api_urls.dart';
import '../../res/color/app_colors.dart';
import '../../res/routes/routes_name.dart';
import '../../utils/file_utils.dart';
import '../../utils/local_file_manager.dart';
import '../../utils/notification_mute_manager.dart';
import '../../view_models/controller/profile/user_profile_controller.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatProfile {
  final String name;
  final String? username;
  final String userId;
  final String profileImageUrl;

  ChatProfile({
    required this.name,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
  });
}

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({super.key});

  @override
  _ChatProfileScreenState createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen> {
  final UserProfileController _profileController =
      Get.put(UserProfileController());
  final ChatProfile chatProfile = Get.arguments as ChatProfile;

  // List<String> mediaFileList = List.empty();
  List<Media> userMediaFileList = List.empty();
  List<String> linkList = List.empty();
  List<String> docLinkList = List.empty();
  List<String> groupList = List.empty();

  final LocalFileManager _localFileManager = LocalFileManager();

  bool _isNotificationsMuted = false;

  @override
  void initState() {
    super.initState();
    _loadUserFiles();

    _checkMuteStatus();
  }

  Future<void> _loadUserFiles() async {
    try {
      await _profileController.mediaListApi("private", chatProfile.userId);
      if (_profileController.rxRequestStatus.value == Status.COMPLETED) {
        setState(() {
          userMediaFileList = _profileController.userMediaList.toList();
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
    // mediaFileList = await _localFileManager.getFilePaths(FileTypeFormat.media);
    // linkList = await _localFileManager.getFilePaths(FileTypeFormat.link);
    // docLinkList = await _localFileManager.getFilePaths(FileTypeFormat.document);
    // groupList = await _localFileManager.getFilePaths(FileTypeFormat.other);
  }

  @override
  Widget build(BuildContext context) {
    // _loadUserFiles();

    var profileVal = chatProfile;

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: profileVal.profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                              profileVal.profileImageUrl)
                          : AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Text(
                      profileVal.name,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Last seen just now",
                      style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 13,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    SizedBox(height: 6),
                    if (profileVal.username?.isNotEmpty == true)
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          profileVal.username ?? '',
                          style: TextStyle(
                              color: Colors.white70,
                              fontFamily: AppFonts.opensansRegular),
                        ),
                      ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          _isNotificationsMuted
                              ? Icons.notifications_on
                              : Icons.notifications_off,
                          _isNotificationsMuted ? 'Unmute' : 'Mute',
                          () async {
                            await NotificationMuteUtil.toggleMute(context);

                            _checkMuteStatus();
                          },
                        ),
                        _buildActionButton(context, Icons.call, 'Call', () {
                          Get.toNamed(RouteName.newMeetingScreen);
                        }),
                        // _buildActionButton(Icons.search, 'Search', () {}),
                        _buildActionButton(context, Icons.more_horiz, 'More',
                            () {
                          _showMoreMenu(context);
                        }),
                      ],
                    ),
                    SizedBox(height: 18),
                  ],
                ),
              ),
              DefaultTabController(
                length: 1,
                // length: 4,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor:
                          Theme.of(context).textTheme.bodyLarge?.color,
                      labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      tabs: [
                        Tab(
                          icon: Icon(Icons.image, size: 16),
                          text: "Media",
                        ),
                      ],
                    ),
                    // Expanded the TabBarView to fill available area
                    SizedBox(
                      height: 350,
                      child: TabBarView(
                        children: [
                          _buildMediaGridFromMedia(userMediaFileList),
                          // _buildMediaGrid(mediaFileList),
                          // _buildLinkList(linkList),
                          // _buildDocList(docLinkList),
                          // Center(child: Text("No Groups")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkMuteStatus() async {
    final isMuted = await NotificationMuteUtil.isMuted();
    setState(() {
      _isNotificationsMuted = isMuted;
    });
  }

  Widget _buildActionButton(BuildContext buttonContext, IconData icon,
      String label, VoidCallback onTap) {
    return Column(
      children: [
        Builder(
          builder: (buttonContext) => InkWell(
            onTap: () => onTap(),
            // pass the context of InkWell
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(14),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showMoreMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + buttonSize.height,
      overlay.size.width - (buttonPosition.dx + buttonSize.width),
      overlay.size.height - (buttonPosition.dy + buttonSize.height),
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.grey.shade50,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        PopupMenuItem(
          value: 'view_profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('View Social Profile'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 10,
          ),
        ),
        PopupMenuItem(
          value: 'block_user',
          child: ListTile(
            leading: Icon(Icons.block, color: Colors.red),
            title: Text('Block User', style: TextStyle(color: Colors.red)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 8,
          ),
        ),
      ],
      elevation: 8,
    ).then((selected) async {
      if (selected != null) {
        print('Selected: $selected');
        switch (selected) {
          case 'view_profile':
            Get.toNamed(
              RouteName.clipProfieScreen,
              arguments: chatProfile.userId,
            );
            break;
          case 'block_user':
            await blockUser();
            break;
          default:
            break;
        }
      }
    });
  }

  Widget _buildMediaGrid(List<String> mediaPaths) {
    if (mediaPaths.isEmpty) {
      return Center(child: Text('No media files'));
    }

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];

    return GridView.builder(
      padding: EdgeInsets.all(6),
      itemCount: mediaPaths.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final path = mediaPaths[index];
        if (path.isEmpty) {
          return Container();
        }
        final extension = p.extension(path).toLowerCase();

        final isImage = imageExtensions.contains(extension);

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isImage
              ? (path.startsWith('http')
                  ? Image.network(path, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderIcon(extension);
                    })
                  : File(path).existsSync()
                      ? Image.file(File(path), fit: BoxFit.cover)
                      : _buildPlaceholderIcon(extension))
              : _buildPlaceholderIcon(extension),
        );
      },
    );
  }

  Widget _buildMediaGridFromMedia(List<Media> mediaPaths) {
    if (mediaPaths.isEmpty) {
      return Center(child: Text('No media files'));
    }

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    final documentExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt'
    ];

    return GridView.builder(
      padding: EdgeInsets.all(6),
      itemCount: mediaPaths.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final media = mediaPaths[index];
        final path = media.content;

        if (path.isEmpty) return Container();

        final extension = p.extension(path).toLowerCase();
        final fileName = p.basename(path);
        final isImage = imageExtensions.contains(extension);
        final isVideo = videoExtensions.contains(extension);
        final isDocument = documentExtensions.contains(extension);
        final isLink =
            path.startsWith('http') && !isImage && !isVideo && !isDocument;

        Widget contentWidget;

        if (isImage) {
          contentWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: path.startsWith('http')
                ? Image.network(path, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderIcon(extension);
                  })
                : File(path).existsSync()
                    ? Image.file(File(path), fit: BoxFit.cover)
                    : _buildPlaceholderIcon(extension),
          );
        } else if (isVideo) {
          contentWidget = Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black26,
                ),
                child: Center(
                  child: Icon(Icons.videocam, size: 40, color: Colors.white),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: () {
                    FileUtils.openFileWithSystemApp(
                        context, path, fileName, _localFileManager);
                  }),
                ),
              ),
            ],
          );
        } else if (isDocument) {
          final iconData = FileUtils.getFileIcon(extension);
          contentWidget = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.blueGrey.shade50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 36, color: Colors.blueGrey),
                SizedBox(height: 4),
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        } else if (isLink) {
          contentWidget = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.teal.shade50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link, size: 36, color: Colors.teal),
                SizedBox(height: 4),
                Text(
                  path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        } else {
          // Fallback for unknown types
          contentWidget = _buildPlaceholderIcon(extension);
        }

        return GestureDetector(
          onTap: () {
            if (isImage || isVideo || isDocument) {
              FileUtils.openFile(context, path, fileName, _localFileManager);
            } else if (isLink) {
              FileUtils.openFileWithSystemApp(
                  context, path, "Link", _localFileManager);
            } else {
              // Unknown or unsupported type
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unsupported file type')),
              );
            }
          },
          child: contentWidget,
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(String extension) {
    final icon = FileUtils.getFileIcon(extension);
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildLinkList(List<String> links) {
    if (links.isEmpty) {
      return Center(child: Text('No links'));
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        if (link.isEmpty) {
          return Container();
        }
        return ListTile(
          leading: Icon(Icons.link_outlined),
          title: Text(link, overflow: TextOverflow.ellipsis),
          onTap: () {
            // Open web link or file url with system app
            FileUtils.openFileWithSystemApp(
                context, link, "Link", _localFileManager);
          },
        );
      },
    );
  }

  Widget _buildDocList(List<String> docs) {
    if (docs.isEmpty) {
      return Center(child: Text('No documents'));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final path = docs[index];
        if (path.isEmpty) {
          return Container();
        }
        final fileName = p.basename(path);
        final extension = p.extension(path).toLowerCase();
        final iconData = FileUtils.getFileIcon(extension);

        return ListTile(
          leading: Icon(iconData, color: Colors.blueGrey),
          title: Text(fileName, overflow: TextOverflow.ellipsis),
          onTap: () {
            FileUtils.openFile(context, path, fileName, _localFileManager);
          },
        );
      },
    );
  }

  Future<void> blockUser() async {
    final UserPreferencesViewmodel userPreferences = UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }
    if (chatProfile.userId.isNotEmpty == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid user data found')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/block-user/${chatProfile.userId}'), // Replace with actual endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'User blocked successfully.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            message,
            style: TextStyle(color: Colors.red),
          )),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to block user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
