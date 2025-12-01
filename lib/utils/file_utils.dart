import 'package:connectapp/utils/local_file_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view/message/audioplayerstate.dart';
import '../view/message/videoplayer.dart';

class FileUtils {
  static String getFileType(String path) {
    final extension = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image/$extension';
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv', '3gp', 'webm']
        .contains(extension)) {
      return 'video/$extension';
    } else if (['mp3', 'aac', 'wav', 'ogg', 'm4a', 'flac']
        .contains(extension)) {
      return 'audio/$extension';
    } else if (['pdf'].contains(extension)) {
      return 'application/pdf';
    } else if (['doc', 'docx'].contains(extension)) {
      return 'application/msword';
    } else if (['xls', 'xlsx'].contains(extension)) {
      return 'application/vnd.ms-excel';
    } else if (['txt'].contains(extension)) {
      return 'text/plain';
    } else {
      return 'application/octet-stream';
    }
  }

  static void openFile(BuildContext context, String fileUrl, String fileName,
      LocalFileManager localFileManager) {
    final fileType = getFileType(fileName);

    if (fileType.startsWith('image/')) {
      showImageFullScreen(context, fileUrl, fileName, localFileManager);
    } else if (fileType.startsWith('video/')) {
      showVideoFullScreen(context, fileUrl, fileName, localFileManager);
    } else if (fileType.startsWith('audio/')) {
      showAudioPlayer(context, fileUrl, fileName, localFileManager);
    } else {
      openFileWithSystemApp(context, fileUrl, fileName, localFileManager);
    }
  }

  static void showImageFullScreen(BuildContext context, String imageUrl,
      String fileName, LocalFileManager localFileManager) {
    localFileManager.addFilePath(FileTypeFormat.media, imageUrl);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stack) {
                      return const Center(
                        child: Text('Failed to load image',
                            style: TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // File Name
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Text(
                  fileName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------------------------
  // WhatsApp-style responsive video preview
  //--------------------------------------------------------------------
  static void showVideoFullScreen(BuildContext context, String videoUrl,
      String fileName, LocalFileManager localFileManager) {
    localFileManager.addFilePath(FileTypeFormat.media, videoUrl);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return VideoPlayerDialog(
          videoUrl: videoUrl,
          fileName: fileName,
        );
      },
    );
  }

  //--------------------------------------------------------------------
  // Responsive audio player dialog
  //--------------------------------------------------------------------
  static void showAudioPlayer(BuildContext context, String audioUrl,
      String fileName, LocalFileManager localFileManager) {
    localFileManager.addFilePath(FileTypeFormat.media, audioUrl);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          backgroundColor: Colors.black,
          child: AudioPlayerDialog(
            audioUrl: audioUrl,
            fileName: fileName,
          ),
        );
      },
    );
  }

  //--------------------------------------------------------------------
  // File launcher for PDF, DOC, XLS, etc.
  //--------------------------------------------------------------------
  static Future<void> openFileWithSystemApp(
      BuildContext context,
      String fileUrl,
      String fileName,
      LocalFileManager localFileManager) async {
    try {
      final Uri url = Uri.parse(fileUrl);

      bool launched = false;

      localFileManager.addFilePath(FileTypeFormat.document, fileUrl);

      // 1. Try external app
      try {
        if (await canLaunchUrl(url)) {
          launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}

      // 2. Try platform default
      if (!launched) {
        try {
          launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      // 3. Try in-app webview
      if (!launched) {
        try {
          launched = await launchUrl(url,
              mode: LaunchMode.inAppWebView,
              webViewConfiguration: const WebViewConfiguration(
                enableJavaScript: true,
                enableDomStorage: true,
              ));
        } catch (_) {}
      }

      if (!launched) {
        showSnackBar(context, "Cannot open this file. Install a suitable app.");
      }
    } catch (e) {
      showSnackBar(context, "Error: $e");
    }
  }

  //--------------------------------------------------------------------
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //--------------------------------------------------------------------
  // File Icon
  //--------------------------------------------------------------------
  static IconData getFileIcon(String pathOrExtension) {
    String ext = pathOrExtension.toLowerCase();

    if (ext.contains('.') && !ext.startsWith('.')) {
      ext = ext.split('.').last;
    }
    ext = '.$ext';

    switch (ext) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.grid_on;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.txt':
        return Icons.notes;
      case '.zip':
      case '.rar':
        return Icons.archive;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return Icons.videocam;
      case '.mp3':
      case '.wav':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  //--------------------------------------------------------------------
  // Open URL
  //--------------------------------------------------------------------
  static Future<void> openUrl(BuildContext context, String url,
      LocalFileManager localFileManager) async {
    try {
      final uri = Uri.parse(url);
      bool launched = false;

      localFileManager.addFilePath(FileTypeFormat.link, url);

      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }

      if (!launched) {
        showSnackBar(context, "Cannot open URL.");
      }
    } catch (e) {
      showSnackBar(context, "Invalid URL");
    }
  }
}
