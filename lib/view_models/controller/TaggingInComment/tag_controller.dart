import 'package:get/get.dart';
import '../../../models/AllFollowers/all_followers_model.dart';

class TaggingController extends GetxController {
  var showTagList = false.obs;
  var query = ''.obs;
  var filteredFollowers = <Followers>[].obs;

  void filterFollowers(String text, List<Followers> followers) {
    query.value = text;

    // Show all followers when @ is typed without any text after it
    if (text.isEmpty) {
      filteredFollowers.value = followers;
      showTagList.value = followers.isNotEmpty;
      return;
    }

    // Filter followers based on username
    filteredFollowers.value = followers
        .where((f) =>
            f.follower?.username?.toLowerCase().contains(text.toLowerCase()) ??
            false)
        .toList();

    showTagList.value = filteredFollowers.isNotEmpty;
  }

  void hideTagList() {
    showTagList.value = false;
    filteredFollowers.clear();
  }
}
