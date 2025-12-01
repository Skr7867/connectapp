import 'dart:convert';
import 'dart:developer';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'save_avatar_screen.dart';

class AvatarCreatorScreen extends StatefulWidget {
  const AvatarCreatorScreen({super.key});

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen> {
  late final WebViewController _controller;
  String? glbUrl;
  String? pngUrl;
  String? lastProcessedUrl;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'ReadyPlayerMe',
        onMessageReceived: (JavaScriptMessage message) {
          // Check for raw .glb URL first
          if (message.message.endsWith('.glb')) {
            final avatarUrl = message.message;
            // Avoid processing the same URL multiple times
            if (avatarUrl == lastProcessedUrl) {
              return;
            }

            final previewUrl = avatarUrl.replaceAll('.glb', '.png');

            setState(() {
              glbUrl = avatarUrl;
              pngUrl = previewUrl;
              lastProcessedUrl = avatarUrl;
            });

            // Navigate to SaveAvatarPage
            if (glbUrl != null && pngUrl != null) {
              log("➡️ Navigating to SaveAvatarPage");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SaveAvatarPage(glbUrl: glbUrl!, pngUrl: pngUrl!),
                  ),
                );
              });
            }
            return;
          }

          // Try parsing as JSON for other events
          try {
            final Map<String, dynamic>? jsonMsg = jsonDecode(message.message);

            if (jsonMsg == null) {
              return;
            }

            final eventName = jsonMsg['eventName'];
            final source = jsonMsg['source'];
            final data = jsonMsg['data'];

            if (source == "readyplayerme" &&
                (eventName == "v2.avatar.exported" ||
                    eventName == "v1.avatar.exported")) {
              final avatarUrl = data['url'];

              if (avatarUrl == lastProcessedUrl) {
                return;
              }

              final previewUrl =
                  avatarUrl.toString().replaceAll(".glb", ".png");

              setState(() {
                glbUrl = avatarUrl;
                pngUrl = previewUrl;
                lastProcessedUrl = avatarUrl;
              });

              // Navigate to SaveAvatarPage
              if (glbUrl != null && pngUrl != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SaveAvatarPage(glbUrl: glbUrl!, pngUrl: pngUrl!),
                    ),
                  );
                });
              } else {}
            }
          } catch (e) {
            log("Error parsing JSON message: $e");
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => log('WebView loading: $progress%'),
          onPageStarted: (url) => log('Page started loading: $url'),
          onPageFinished: (url) {
            log('✅ Page finished loading: $url');
            _injectJavascriptListener();
          },
          onWebResourceError: (err) {},
        ),
      )
      ..loadRequest(
        Uri.parse("https://connectapp.readyplayer.me/avatar?"),
      );
  }

  void _injectJavascriptListener() {
    _controller.runJavaScript('''
      window.addEventListener("message", (event) => {
        console.log("JS Listener: Received message", event.data);
        if (typeof event.data === "string" && event.data.endsWith(".glb")) {
          ReadyPlayerMe.postMessage(event.data);
        } else if (event.data && event.data.source === "readyplayerme") {
          ReadyPlayerMe.postMessage(JSON.stringify(event.data));
        }
      });
    ''').catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          "Create your avatar",
          style: TextStyle(
            fontFamily: AppFonts.opensansRegular,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
