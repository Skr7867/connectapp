// import 'dart:io';

// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagePickerController extends GetxController {
//   var pickedImage = Rx<File?>(null);

//   Future<void> pickImageFromGallery({Function(File)? onImagePicked}) async {
//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       final file = File(image.path);
//       pickedImage.value = file;
//       if (onImagePicked != null) onImagePicked(file);
//     }
//   }

//   Future<void> pickImageFromCamera({Function(File)? onImagePicked}) async {
//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       final file = File(image.path);
//       pickedImage.value = file;
//       if (onImagePicked != null) onImagePicked(file);
//     }
//   }

//   void clearImage() {
//     pickedImage.value = null;
//   }
// }

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  Future<void> pickImageFromGallery({Function(File)? onImagePicked}) async {
    try {
      isLoading(true);
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        pickedImage.value = file;
        onImagePicked?.call(file);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImageFromCamera({Function(File)? onImagePicked}) async {
    try {
      isLoading(true);
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        pickedImage.value = file;
        onImagePicked?.call(file);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void clearImage() {
    pickedImage.value = null;
  }

  void setNetworkImage(String url) {
    // If you need to handle network images
    pickedImage.value = null; // Reset first
    // You'd typically download the image here
  }
}
