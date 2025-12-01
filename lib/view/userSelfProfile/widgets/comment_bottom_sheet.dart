import 'package:connectapp/res/color/app_colors.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/fonts/app_fonts.dart';
import '../../../view_models/controller/TaggingInComment/tag_controller.dart';
import '../../../view_models/controller/allFollowers/all_followers_controller.dart';
import '../../../view_models/controller/deleteComment/delete_comment_controller.dart';
import '../../../view_models/controller/getClipByid/comment_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';

class CommentsBottomSheet extends StatelessWidget {
  final String clipId;
  final CommentsController controller = Get.put(CommentsController());
  final allFollowersController = Get.put(AllFollowersController());
  final taggingController = Get.put(TaggingController());
  CommentsBottomSheet({super.key, required this.clipId});

  @override
  Widget build(BuildContext context) {
    controller.fetchComments(clipId);
    void insertTagToInput(String username) {
      String text = controller.commentText.value;
      int cursorIndex = text.length;
      int tagStart = text.lastIndexOf('@', cursorIndex - 1);

      if (tagStart != -1) {
        String newText =
            "${text.substring(0, tagStart + 1)}$username ${text.substring(cursorIndex)}";

        controller.commentText.value = newText;
        taggingController.hideTagList();
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Obx(() => Text(
                      '${controller.comments.length} Comments',
                      style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      size: 24),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800], height: 1),
          Obx(() => controller.replyingToCommentId.value != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[900],
                  child: Row(
                    children: [
                      Text(
                        'Replying to @${controller.replyingToUsername.value}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: controller.cancelReply,
                        child: Icon(Icons.close,
                            color: Colors.grey[400], size: 16),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => _buildShimmerComment(),
                    )
                  : controller.comments.isEmpty
                      ? Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular,
                                fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.comments.length,
                          itemBuilder: (context, index) => _buildComment(
                              controller.comments[index], controller, context),
                        ),
            ),
          ),
          Obx(() {
            if (!taggingController.showTagList.value ||
                taggingController.filteredFollowers.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 188, 227, 247),
                  border: Border.all(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(10)),
              child: ListView.builder(
                itemCount: taggingController.filteredFollowers.length,
                itemBuilder: (context, index) {
                  final follower = taggingController.filteredFollowers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        follower.follower!.avatar?.imageUrl ?? "",
                      ),
                    ),
                    title: Text(
                      "@${follower.follower!.username}",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular),
                    ),
                    onTap: () => insertTagToInput(
                        follower.follower!.username.toString()),
                  );
                },
              ),
            );
          }),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Expanded(child: Obx(() {
                  return TextField(
                    controller: TextEditingController(
                        text: controller.commentText.value)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                            offset: controller.commentText.value.length),
                      ),
                    onChanged: (value) {
                      controller.commentText.value = value;
                      final cursorIndex = value.length;

                      // detect @
                      int tagStart = value.lastIndexOf('@', cursorIndex - 1);

                      if (tagStart != -1) {
                        final tagText = value.substring(tagStart + 1);

                        // stop showing suggestions on space or empty
                        if (tagText.contains(" ") || tagText.isEmpty) {
                          taggingController.hideTagList();
                        } else {
                          taggingController.filterFollowers(
                            tagText,
                            allFollowersController.followers,
                          );
                        }
                      } else {
                        taggingController.hideTagList();
                      }
                    },
                    onSubmitted: (_) => controller.sendComment(
                      clipId,
                      controller.commentText.value,
                    ),
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  );
                })),
                const SizedBox(width: 8),
                Obx(() => GestureDetector(
                      onTap: controller.isSendingComment.value
                          ? null
                          : () => controller.sendComment(
                              clipId, controller.commentText.value),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: controller.isSendingComment.value
                              ? Colors.grey
                              : (controller.commentText.value.trim().isEmpty
                                  ? Colors.grey
                                  : Colors.blue),
                          shape: BoxShape.circle,
                        ),
                        child: controller.isSendingComment.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send,
                                color: Colors.white, size: 20),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerComment() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(
      dynamic comment, CommentsController controller, context) {
    final deleteController = Get.put(DeleteCommentController());
    final userPrefs = UserPreferencesViewmodel();

    final user = comment['userId'];
    final userAvatar = user['avatar']?['imageUrl'];
    final username = user['username'] ?? 'Unknown';
    final commentOwnerId = user['_id'];
    final content = comment['content'] ?? '';
    final createdAt = comment['createdAt'];
    final likes = comment['likes'] as List<dynamic>? ?? [];
    final replies = comment['replies'] as List<dynamic>? ?? [];
    final commentId = comment['_id'];

    return FutureBuilder(
      future: userPrefs.getUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        final currentUserId = snapshot.data!.user.id.toString();
        final isMyComment = (currentUserId == commentOwnerId);

        return Obx(() {
          final isTranslated = controller.isCommentTranslated(commentId);
          final isTranslating = controller.isCommentTranslating(commentId);
          final displayContent = isTranslated
              ? controller.getTranslatedCommentText(commentId)
              : content;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: userAvatar != null
                              ? CachedNetworkImageProvider(userAvatar)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Username + Time + Delete Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@$username',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontFamily: AppFonts.opensansRegular,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.getTimeAgo(createdAt),
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),

                              Spacer(),

                              // SHOW DELETE ONLY IF THIS IS MY COMMENT
                              if (isMyComment)
                                Obx(() {
                                  return IconButton(
                                    onPressed: deleteController.isDeleting.value
                                        ? null
                                        : () {
                                            deleteController
                                                .deleteComment(commentId);
                                          },
                                    icon: deleteController.isDeleting.value
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.redColor,
                                            ),
                                          )
                                        : Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.redColor,
                                          ),
                                  );
                                })
                            ],
                          ),

                          buildTaggedText(displayContent, context),

                          const SizedBox(height: 8),

                          /// Like, Reply, Translate
                          Row(
                            children: [
                              Obx(() {
                                bool isLiked =
                                    controller.likedComments[commentId] ??
                                        false;
                                int count = controller.likeCount[commentId] ??
                                    likes.length;

                                return GestureDetector(
                                  onTap: () {
                                    controller.toggleLike(
                                        commentId, likes.length);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey[400],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () =>
                                    controller.startReply(commentId, username),
                                child: Text(
                                  'Reply',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: AppFonts.opensansRegular,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildCommentTranslationButton(
                                  controller,
                                  commentId,
                                  content,
                                  isTranslated,
                                  isTranslating),
                            ],
                          ),

                          if (isTranslated || isTranslating)
                            _buildTranslationStatus(
                                isTranslated, isTranslating),
                        ],
                      ),
                    ),
                  ],
                ),

                /// Replies section
                if (replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 52, top: 8),
                    child: Column(
                      children: replies
                          .map<Widget>((reply) =>
                              _buildReply(reply, controller, context))
                          .toList(),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildReply(
      dynamic reply, CommentsController controller, BuildContext context) {
    final user = reply['userId'];
    final userAvatar = user['avatar']?['imageUrl'];
    final username = user['username'] ?? 'Unknown';
    final content = reply['content'] ?? '';
    final createdAt = reply['createdAt'];
    final replyId = reply['_id'];

    return Obx(() {
      // Get translation state for reply - wrapped in Obx to observe changes
      final isTranslated = controller.isCommentTranslated(replyId);
      final isTranslating = controller.isCommentTranslating(replyId);
      final displayContent =
          isTranslated ? controller.getTranslatedCommentText(replyId) : content;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: userAvatar != null
                      ? CachedNetworkImageProvider(userAvatar)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '@$username',
                        style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.getTimeAgo(createdAt),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  buildTaggedText(displayContent, context),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Translation button for reply
                      _buildReplyTranslationButton(controller, replyId, content,
                          isTranslated, isTranslating),
                    ],
                  ),
                  // Translation status for reply
                  if (isTranslated || isTranslating)
                    _buildReplyTranslationStatus(isTranslated, isTranslating),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Highlight tagged text like @username
  Widget buildTaggedText(String text, BuildContext context) {
    final allFollowersController = Get.find<AllFollowersController>();

    final RegExp tagRegex = RegExp(r'@\w+');

    List<InlineSpan> spans = [];
    int start = 0;

    for (final match in tagRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        );
      }

      String tagText = match.group(0)!; // @john
      String cleanName = tagText.replaceFirst('@', '');

      // 🔍 FIND USER FROM FOLLOWERS LIST
      final matchedUser = allFollowersController.followers.firstWhereOrNull(
        (item) => item.follower!.username == cleanName,
      );

      String? userId = matchedUser?.follower?.sId;

      spans.add(
        TextSpan(
          text: tagText,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (userId != null) {
                Get.toNamed(RouteName.clipProfieScreen, arguments: userId);
              } else {
                print("No user found for @$cleanName");
              }
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        children: spans,
      ),
    );
  }

  // Translation button for main comments
  Widget _buildCommentTranslationButton(CommentsController controller,
      String commentId, String content, bool isTranslated, bool isTranslating) {
    return GestureDetector(
      onTap: isTranslating
          ? null
          : () => controller.handleCommentTranslation(commentId, content),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6), // larger tappable area
        decoration: BoxDecoration(
          // Always show a blue-accented button. Use a lighter blue bg when not translated,
          // and slightly stronger blue when translated to indicate "Original" state.
          color: isTranslated
              ? Colors.blue.withOpacity(0.18)
              : Colors.blue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors
                .blue, // keep border blue so it stands out on dark background
            width: 1,
          ),
        ),
        child: isTranslating
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate,
                    size: 14,
                    color: isTranslated ? Colors.blue : Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isTranslated ? 'Original' : 'Translate',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildReplyTranslationButton(CommentsController controller,
      String replyId, String content, bool isTranslated, bool isTranslating) {
    return GestureDetector(
      onTap: isTranslating
          ? null
          : () => controller.handleCommentTranslation(replyId, content),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isTranslated
              ? Colors.blue.withOpacity(0.16)
              : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue,
            width: 0.8,
          ),
        ),
        child: isTranslating
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate,
                    size: 12,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTranslated ? 'Original' : 'Translate',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Translation status indicator for main comments
  Widget _buildTranslationStatus(bool isTranslated, bool isTranslating) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (isTranslated) ...[
            Icon(
              Icons.translate,
              size: 10,
              color: Colors.green.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Translated',
              style: TextStyle(
                color: Colors.green.withOpacity(0.7),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (isTranslating) ...[
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Translating...',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Translation status indicator for replies
  Widget _buildReplyTranslationStatus(bool isTranslated, bool isTranslating) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          if (isTranslated) ...[
            Icon(
              Icons.translate,
              size: 8,
              color: Colors.green.withOpacity(0.7),
            ),
            const SizedBox(width: 2),
            Text(
              'Translated',
              style: TextStyle(
                color: Colors.green.withOpacity(0.7),
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (isTranslating) ...[
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 1.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'Translating...',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
