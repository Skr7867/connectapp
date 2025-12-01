import 'package:connectapp/models/UserLogin/user_login_model.dart';
import 'package:connectapp/view/message/community.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../res/api_urls/api_urls.dart';
import '../modals/modal_screen.dart';

class Clip {
  final String id;
  final String userId;
  final String clipId;
  final String caption;
  final List<String> tags;
  final String status;
  final String createdAt;
  final String? originalFileName;
  final String? processedKey;
  final String? processedUrl;
  final String? thumbnailKey;
  final String? thumbnailUrl;
  final List<dynamic> comments;

  Clip({
    required this.id,
    required this.userId,
    required this.clipId,
    required this.caption,
    required this.tags,
    required this.status,
    required this.createdAt,
    this.originalFileName,
    this.processedKey,
    this.processedUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    required this.comments,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      clipId: json['clipId'] ?? '',
      caption: json['caption'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      originalFileName: json['originalFileName'],
      processedKey: json['processedKey'],
      processedUrl: json['processedUrl'],
      thumbnailKey: json['thumbnailKey'],
      thumbnailUrl: json['thumbnailUrl'],
      comments: json['comments'] ?? [],
    );
  }
}

class ClipProfileScreen extends StatefulWidget {
  final String userId;

  const ClipProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  _ClipProfileScreenState createState() => _ClipProfileScreenState();
}

class _ClipProfileScreenState extends State<ClipProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? profile;
  bool isLoading = true;
  bool isLoadingClips = true;
  String? error;
  List<User> users = [];
  List<Clip> userClips = [];

  Future<void> fetchUserClips() async {
    final UserPreferencesViewmodel userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (token == null) {
      setState(() {
        isLoadingClips = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      setState(() {
        isLoadingClips = true;
      });

      final response = await http.get(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/clip/user-clips/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userClips = (data['clips'] as List)
              .map((clip) => Clip.fromJson(clip))
              .toList();
          isLoadingClips = false;
        });
      } else {
        throw Exception('Failed to load user clips');
      }
    } catch (e) {
      setState(() {
        isLoadingClips = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading clips: $e')),
      );
    }
  }

  Future<void> fetchUsers() async {
    final UserPreferencesViewmodel userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication token not found'),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/show-all-users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = (data['users'] as List)
              .map((user) => User.fromJson(user))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProfile();
    fetchUsers();
    fetchUserClips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    final UserPreferencesViewmodel userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (token == null) {
      setState(() {
        error = 'Authentication token not found';
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/get-user-profile/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final profileResponse =
            ProfileResponse.fromJson(json.decode(response.body));
        setState(() {
          profile = profileResponse.profile;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load profile';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    final UserPreferencesViewmodel userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (profile == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to perform action'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool currentFollowState = profile!.isFollowing;
    final int currentFollowerCount = profile!.followerCount;

    // Optimistically update the UI immediately
    setState(() {
      profile!.isFollowing = !currentFollowState;
      // Update follower count optimistically
      if (currentFollowState) {
        // Unfollowing - decrease count
        profile!.followerCount = currentFollowerCount - 1;
      } else {
        // Following - increase count
        profile!.followerCount = currentFollowerCount + 1;
      }
    });

    try {
      http.Response response;

      if (currentFollowState) {
        // Unfollow - DELETE request
        response = await http.delete(
          Uri.parse(
              '${ApiUrls.baseUrl}/connect/v1/api/social/unfollow-user/${profile!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        // Follow - POST request
        response = await http.post(
          Uri.parse(
              '${ApiUrls.baseUrl}/connect/v1/api/social/follow-user/${profile!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                (!currentFollowState
                    ? 'Followed successfully'
                    : 'Unfollowed successfully')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Error - revert the optimistic update
        setState(() {
          profile!.isFollowing = currentFollowState;
          profile!.followerCount = currentFollowerCount;
        });

        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Failed to ${currentFollowState ? 'unfollow' : 'follow'} user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error - revert the optimistic update
      setState(() {
        profile!.isFollowing = currentFollowState;
        profile!.followerCount = currentFollowerCount;
      });

      print('Error in toggleFollow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> blockUser() async {
    final UserPreferencesViewmodel userPreferences =
        UserPreferencesViewmodel();
    LoginResponseModel? userData = await userPreferences.getUser();
    final token = userData?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/social/block-user/${widget.userId}'), // Replace with actual endpoint
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.block, color: Colors.black),
            onPressed: () {
              blockUser();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Share profile
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error!),
                      ElevatedButton(
                        onPressed: fetchProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : profile == null
                  ? const Center(
                      child: Text('No profile data'),
                    )
                  : Column(
                      children: [
                        _buildProfileHeader(),
                        _buildActionButtons(),
                        _buildTabBar(),
                        Expanded(child: _buildTabBarView()),
                      ],
                    ),
    );
  }

  Widget _buildProfileHeader() {
    if (profile == null) return Container();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundImage: profile!.avatar != null
                ? NetworkImage(profile!.avatar!.imageUrl)
                : null,
            child: profile!.avatar == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 12),

          // Full Name
          Text(
            profile!.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Username
          Text(
            '@${profile!.username}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 8),

          // Level and XP
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                'Level ${profile!.level}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.money, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                'Coins ${profile!.wallet.coins}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.bolt, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'XP ${profile!.xp}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row - Updated to show actual clips count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Posts', '${userClips.length}'),
              _buildStatItem('Followers', '${profile!.followerCount}'),
              _buildStatItem('Following', '${profile!.followingCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (profile == null) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    profile!.isFollowing ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(profile!.isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Send message functionality
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'Posts'),
          Tab(text: 'Followers'),
          Tab(text: 'Following'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsGrid(),
        _buildFollowersList(),
        _buildFollowingList(),
      ],
    );
  }

  Widget _buildPostsGrid() {
    if (isLoadingClips) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userClips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Posts will appear here once uploaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1, // Square aspect ratio like Instagram
      ),
      itemCount: userClips.length,
      itemBuilder: (context, index) {
        final clip = userClips[index];

        return GestureDetector(
          onTap: () {
            // Navigate to video player or detail view
            // You can pass the clip data to a video player screen

            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => VideoPlayerScreen(clip: clip),
            // ));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: clip.thumbnailUrl != null &&
                          clip.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          clip.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.video_library_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.video_library_outlined,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                ),

                // Play button overlay
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowersList() {
    if (profile == null) return Container();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile!.followerCount,
      itemBuilder: (context, index) {
        return _buildUserListItem(
          name: 'Follower ${index + 1}',
          username: 'follower$index',
          isFollowing: false,
        );
      },
    );
  }

  Widget _buildFollowingList() {
    if (profile == null) return Container();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile!.followingCount,
      itemBuilder: (context, index) {
        return _buildUserListItem(
          name: 'Following ${index + 1}',
          username: 'following$index',
          isFollowing: true,
        );
      },
    );
  }

  Widget _buildUserListItem({
    required String name,
    required String username,
    required bool isFollowing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 12),
                    Text(' Level 4', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 8),
                    Icon(Icons.bolt, color: Colors.blue, size: 12),
                    Text(' Coins 100', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 8),
                    Icon(Icons.trending_up, color: Colors.green, size: 12),
                    Text(' XP 1230', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle follow/unfollow for individual users
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey : Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
