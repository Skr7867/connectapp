import 'dart:io';
import 'package:connectapp/data/appexception/app_exception.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/CREATORPANEL/ContenTypeController/content_type_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../repository/CREATORPANEL/CreateLession/create_lession_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class LessonController extends GetxController {
  late final String courseId;
  late final String sectionId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    courseId = args['courseId']?.toString() ?? '';
    sectionId = args['sectionId']?.toString() ?? '';
  }

  final LessonRepository _lessonRepository = LessonRepository();
  final ContentTypeController contentTypeController =
      Get.find<ContentTypeController>();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var title = ''.obs;
  var description = ''.obs;
  var textContent = ''.obs;
  var videoUrl = ''.obs;
  var selectedVideoFile = Rxn<File>();
  var selectedVideoName = ''.obs;

  void setTitle(String value) => title.value = value;
  void setDescription(String value) => description.value = value;
  void setTextContent(String value) => textContent.value = value;
  void setVideoUrl(String value) => videoUrl.value = value;

  Future<void> pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        selectedVideoFile.value = File(result.files.single.path!);
        selectedVideoName.value = result.files.single.name;
        videoUrl.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Error picking video: $e';
      Utils.snackBar('Error', errorMessage.value);
    }
  }

  void removeVideo() {
    selectedVideoFile.value = null;
    selectedVideoName.value = '';
    videoUrl.value = '';
  }

  Future<void> createLesson() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (courseId.isEmpty || sectionId.isEmpty) {
        throw FetchDataException('Course ID and Section ID are required');
      }

      if (title.value.isEmpty) {
        throw FetchDataException('Title is required');
      }

      final token = await _userPreferences.getToken();
      if (token == null) {
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      if (contentTypeController.contentType.value == 'Video' &&
          selectedVideoFile.value == null &&
          videoUrl.value.isEmpty) {
        throw FetchDataException('Video file or URL is required');
      }

      List<Map<String, dynamic>> quizData = [];
      if (contentTypeController.contentType.value == 'Quiz') {
        for (var question in contentTypeController.quizQuestions) {
          if (question.question.value.isEmpty) {
            throw FetchDataException('Quiz question cannot be empty');
          }
          if (question.options.any((option) => option.value.isEmpty)) {
            throw FetchDataException('All quiz options must be filled');
          }
          int? correctAnswerIndex;
          for (int i = 0; i < question.correctAnswer.length; i++) {
            if (question.correctAnswer[i].value) {
              if (correctAnswerIndex != null) {
                throw FetchDataException(
                    'Only one correct answer is allowed per question');
              }
              correctAnswerIndex = i;
            }
          }
          if (correctAnswerIndex == null) {
            throw FetchDataException(
                'Each quiz question must have one correct answer');
          }

          quizData.add({
            'question': question.question.value,
            'options': question.options.map((option) => option.value).toList(),
            'correctAnswer': question.options[correctAnswerIndex].value,
          });
        }
      }

      final lessonData = {
        'title': title.value,
        'description': description.value, // Fixed
        'contentType': contentTypeController.contentType.value.toLowerCase(),
        'textContent': contentTypeController.contentType.value == 'Text'
            ? textContent.value
            : '',
        'video': contentTypeController.contentType.value == 'Video' &&
                selectedVideoFile.value == null
            ? videoUrl.value
            : null,
        'quiz': quizData,
      };

      await _lessonRepository.createLesson(
        courseId: courseId,
        sectionId: sectionId,
        lessonData: lessonData,
        videoFile: contentTypeController.contentType.value == 'Video'
            ? selectedVideoFile.value
            : null,
        token: token,
      );

      Utils.snackBar(
        'Lesson created successfully!',
        'Success',
      );
      Get.offNamed(RouteName.createCourseSectionScreen);
    } catch (e) {
      errorMessage.value = e.toString();
      Utils.snackBar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
