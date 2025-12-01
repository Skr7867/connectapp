import 'package:get/get.dart';

class QuizQuestion {
  RxString question;
  List<RxString> options;
  List<RxBool> correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.empty() {
    return QuizQuestion(
      question: ''.obs,
      options: List.generate(4, (_) => ''.obs),
      correctAnswer: List.generate(4, (_) => false.obs),
    );
  }
}

class ContentTypeController extends GetxController {
  var contentType = 'Text'.obs;
  var quizQuestions = <QuizQuestion>[QuizQuestion.empty()].obs;
  var textContent = ''.obs; // Added for text content
  var videoUrl = ''.obs; // Added for video URL

  void addQuestion() {
    quizQuestions.add(QuizQuestion.empty());
  }

  void removeQuestion(int index) {
    if (quizQuestions.length > 1) {
      quizQuestions.removeAt(index);
    }
  }
}
