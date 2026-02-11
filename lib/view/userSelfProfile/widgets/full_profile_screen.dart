import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullProfileScreen extends StatelessWidget {
  const FullProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = Get.arguments;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Profile',
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 120);
                      },
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 120,
                ),
        ),
      ),
    );
  }
}
