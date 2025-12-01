import 'package:get/get.dart';
import '../../../models/AllFollowers/all_followers_model.dart';

class TaggingController extends GetxController {
  var showTagList = false.obs;
  var query = ''.obs;
  var filteredFollowers = <Followers>[].obs;

  void filterFollowers(String text, List<Followers> followers) {
    query.value = text;

    if (text.isEmpty) {
      showTagList.value = false;
      return;
    }

    filteredFollowers.value = followers
        .where((f) =>
            f.follower!.username!.toLowerCase().contains(text.toLowerCase()))
        .toList();

    showTagList.value = true;
  }

  void hideTagList() {
    showTagList.value = false;
  }
}
