import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/response/status.dart';
import '../../../models/RepostedClips/repsoted_clips_model.dart';
import '../../../repository/RepostedClips/reposted_clips_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class FetchRepostClipsController extends GetxController {
  final _api = RepostedClipsRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final repostedClips = Rxn<RepostedClipsModel>();
  final error = ''.obs;

  DateTime? _lastRefresh;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setRepostedClips(RepostedClipsModel? value) =>
      repostedClips.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchRepostedClips();
  }

  // Load Reposted Clips (with optional refresh)
  Future<void> _loadRepostedClips({bool isRefresh = false}) async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // Only use cache if it has clips
      if (!isRefresh) {
        final cachedData = prefs.getString('reposted_clips_cache');
        if (cachedData != null) {
          final decodedJson = jsonDecode(cachedData) as Map<String, dynamic>;
          final cachedModel = RepostedClipsModel.fromJson(decodedJson);

          if (cachedModel.clips != null && cachedModel.clips!.isNotEmpty) {
            setRepostedClips(cachedModel);
            setRxRequestStatus(Status.COMPLETED);
            return;
          }
        }
      }

      //Always call API if cache is empty or refresh
      final response = await _api.repostedClips(loginData.token);
      setRepostedClips(response);
      setRxRequestStatus(Status.COMPLETED);

      // Save to cache
      await prefs.setString(
        'reposted_clips_cache',
        jsonEncode(response.toJson()),
      );
    } catch (err) {
      // log("Fetch Reposted Clips Error: $err", stackTrace: stack);
      setError(err.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  // Initial fetch
  Future<void> fetchRepostedClips() async {
    await _loadRepostedClips();
  }

  //  Refresh with cooldown (5 seconds)
  Future<void> refreshRepostedClips() async {
    final now = DateTime.now();
    if (_lastRefresh != null && now.difference(_lastRefresh!).inSeconds < 5) {
      return;
    }
    _lastRefresh = now;
    await _loadRepostedClips(isRefresh: true);
  }
}
