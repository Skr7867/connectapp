// import 'package:connectapp/res/color/app_colors.dart';
// import 'package:connectapp/res/fonts/app_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../view_models/CREATORPANEL/ImagePicker/image_picker_controller.dart';

// class CoverImagePicker extends StatelessWidget {
//   const CoverImagePicker({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ImagePickerController());

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () {
//             Get.bottomSheet(
//               Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(16),
//                 child: Wrap(
//                   children: [
//                     ListTile(
//                       leading: Icon(
//                         Icons.photo_library,
//                         color: Theme.of(context).textTheme.bodyLarge?.color,
//                       ),
//                       title: Text(
//                         'Pick from Gallery',
//                         style: TextStyle(
//                             color: Theme.of(context).textTheme.bodyLarge?.color,
//                             fontFamily: AppFonts.opensansRegular),
//                       ),
//                       onTap: () {
//                         controller.pickImageFromGallery();
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         Icons.camera_alt,
//                         color: Theme.of(context).textTheme.bodyLarge?.color,
//                       ),
//                       title: Text(
//                         'Take a Photo',
//                         style: TextStyle(
//                             color: Theme.of(context).textTheme.bodyLarge?.color,
//                             fontFamily: AppFonts.opensansRegular),
//                       ),
//                       onTap: () {
//                         controller.pickImageFromCamera();
//                         Get.back();
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.close, color: Colors.red),
//                       title: const Text(
//                         'Cancel',
//                         style: TextStyle(
//                             color: Colors.red,
//                             fontFamily: AppFonts.opensansRegular),
//                       ),
//                       onTap: () => Get.back(),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(6),
//               color: AppColors.textfieldColor,
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.file_present, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Obx(() {
//                     final file = controller.pickedImage.value;
//                     if (file != null) {
//                       return Text(
//                         file.path.split('/').last,
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontFamily: AppFonts.opensansRegular),
//                         overflow: TextOverflow.ellipsis,
//                       );
//                     } else {
//                       return const Text(
//                         'Choose file',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontFamily: AppFonts.opensansRegular),
//                       );
//                     }
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Obx(() {
//           final file = controller.pickedImage.value;
//           if (file != null) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.file(
//                     file,
//                     width: 150,
//                     height: 110,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 GestureDetector(
//                   onTap: () {
//                     controller.clearImage();
//                   },
//                   child: Text(
//                     "Remove ",
//                     style: TextStyle(
//                         color: Colors.red.shade700,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                         fontFamily: AppFonts.opensansRegular),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const SizedBox.shrink();
//           }
//         }),
//       ],
//     );
//   }
// }

import 'dart:io';

import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/color/app_colors.dart';
import '../../../view_models/CREATORPANEL/ImagePicker/image_picker_controller.dart';

class CoverImagePicker extends StatelessWidget {
  final void Function(File file)? onImageSelected;

  const CoverImagePicker({super.key, this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImagePickerController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.photo_library,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      title: Text(
                        'Pick from Gallery',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        controller.pickImageFromGallery(
                          onImagePicked: (file) {
                            onImageSelected?.call(file);
                          },
                        );
                        Get.back();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      title: Text(
                        'Take a Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        controller.pickImageFromCamera(
                          onImagePicked: (file) {
                            onImageSelected?.call(file);
                          },
                        );
                        Get.back();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                      onTap: () => Get.back(),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.greyColor.withOpacity(0.4),
                )),
            child: Row(
              children: [
                const Icon(
                  Icons.file_present,
                  color: AppColors.textColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final file = controller.pickedImage.value;
                    return Text(
                      file != null ? file.path.split('/').last : 'Choose file',
                      style: TextStyle(
                        color: AppColors.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final file = controller.pickedImage.value;
          if (file != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    width: 150,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    controller.clearImage();
                    onImageSelected
                        ?.call(File('')); // clears in CourseController
                  },
                  child: Text(
                    "Remove ",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }
}
