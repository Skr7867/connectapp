import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

ImageProvider<Object> CacheImageLoader(String? imageUrl, String defaultAssetPath) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      return CachedNetworkImageProvider(imageUrl);
    } catch (e) {
      debugPrint('CacheImageLoader: Failed to load network image → $e');
      return AssetImage(defaultAssetPath);
    }
  } else {
    return AssetImage(defaultAssetPath);
  }
}