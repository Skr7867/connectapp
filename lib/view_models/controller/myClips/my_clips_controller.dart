import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/response/status.dart';
import '../../../models/MyAllClips/my_all_clips_model.dart';
import '../../../repository/MyClips/my_clips_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class MyClipsController extends GetxController {
  final _api = MyClipsRepository();
  final _prefs = UserPreferencesViewmodel();
  final _box = GetStorage();

  // Cache configuration
  static const _cacheKey = 'my_clips_cache';
  static const _cacheTimestampKey = 'my_clips_timestamp';
  static const _cacheDuration = Duration(minutes: 3);
  DateTime? _lastRefresh;

  final rxRequestStatus = Status.COMPLETED.obs; // Start as COMPLETED
  final myClips = Rxn<MyAllClipsModel>();
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setMyClips(MyAllClipsModel? value) => myClips.value = value;

  // Separate getters for public & private clips
  List<Clips> get publicClips =>
      myClips.value?.clips?.where((c) => c.isPrivate == false).toList() ?? [];

  List<Clips> get privateClips =>
      myClips.value?.clips?.where((c) => c.isPrivate == true).toList() ?? [];

  // Check if we have any clips loaded
  bool get hasClips => myClips.value?.clips?.isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadCachedClips(); // Load cache immediately
    _fetchIfStale(); // Fetch only if cache is stale
  }

  /// Load cached clips instantly (no loading state)
  void _loadCachedClips() {
    try {
      final cachedData = _box.read(_cacheKey);
      if (cachedData != null) {
        final clipsModel = MyAllClipsModel.fromJson(jsonDecode(cachedData));
        setMyClips(clipsModel);
        setRxRequestStatus(Status.COMPLETED);
      }
    } catch (e) {
      // Clear corrupted cache
      _clearCache();
    }
  }

  /// Fetch only if cache is stale
  Future<void> _fetchIfStale() async {
    if (!_isCacheStale()) return; // Cache is fresh, skip fetch

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated");
        return;
      }

      final response = await _api.myAllClips(loginData.token);

      // Only update if data actually changed
      if (_hasDataChanged(response)) {
        setMyClips(response);
        _saveCache(response);
      }
    } catch (e) {
      // Silent fail if we have cached data
      if (!hasClips) {
        setError(e.toString());
        setRxRequestStatus(Status.ERROR);
      }
    }
  }

  /// Check if cache is stale
  bool _isCacheStale() {
    final timestamp = _box.read<int>(_cacheTimestampKey);
    if (timestamp == null) return true;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) > _cacheDuration;
  }

  /// Check if data has actually changed
  bool _hasDataChanged(MyAllClipsModel newData) {
    if (myClips.value == null) return true;

    final oldClips = myClips.value?.clips ?? [];
    final newClips = newData.clips ?? [];

    if (oldClips.length != newClips.length) return true;

    // Check if any clip IDs are different
    for (int i = 0; i < newClips.length; i++) {
      if (oldClips[i].sId != newClips[i].sId) return true;
    }

    return false;
  }

  /// Save clips to cache with timestamp
  void _saveCache(MyAllClipsModel data) {
    try {
      _box.write(_cacheKey, jsonEncode(data.toJson()));
      _box.write(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Cache save failed, continue without cache
      print('Failed to save cache: $e');
    }
  }

  /// Clear cache
  void _clearCache() {
    _box.remove(_cacheKey);
    _box.remove(_cacheTimestampKey);
  }

  /// Public fetch method (shows loading only if no data)
  Future<void> fetchMyClips() async {
    // Only show loading if no cached data exists
    if (!hasClips) {
      setRxRequestStatus(Status.LOADING);
    }

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final response = await _api.myAllClips(loginData.token);
      setMyClips(response);
      setRxRequestStatus(Status.COMPLETED);
      _saveCache(response);
    } catch (err) {
      // Keep cached data on error
      if (!hasClips) {
        setError(err.toString());
        setRxRequestStatus(Status.ERROR);
      } else {
        // Show error but keep cached data visible
        setError(err.toString());
      }
    }
  }

  /// Refresh method (for pull-to-refresh)
  Future<void> refreshMyClips() async {
    // Rate limit: prevent refreshing more than once every 5 seconds
    final now = DateTime.now();
    if (_lastRefresh != null && now.difference(_lastRefresh!).inSeconds < 5) {
      return;
    }
    _lastRefresh = now;

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated");
        return;
      }

      final response = await _api.myAllClips(loginData.token);
      setMyClips(response);
      setRxRequestStatus(Status.COMPLETED);
      _saveCache(response);
    } catch (err) {
      setError(err.toString());
      // Don't change status on refresh error
    }
  }

  /// Force refresh (ignores rate limit)
  Future<void> forceRefresh() async {
    _lastRefresh = null;
    await refreshMyClips();
  }

  /// Remove a clip from the list (after delete/archive)
  void removeClip(String clipId) {
    if (myClips.value?.clips != null) {
      myClips.value!.clips!.removeWhere((clip) => clip.sId == clipId);
      myClips.refresh();

      // Update cache
      if (myClips.value != null) {
        _saveCache(myClips.value!);
      }
    }
  }

  /// Update a specific clip (after edit)
  void updateClip(Clips updatedClip) {
    if (myClips.value?.clips != null) {
      final index = myClips.value!.clips!.indexWhere(
        (clip) => clip.sId == updatedClip.sId,
      );

      if (index != -1) {
        myClips.value!.clips![index] = updatedClip;
        myClips.refresh();

        // Update cache
        if (myClips.value != null) {
          _saveCache(myClips.value!);
        }
      }
    }
  }

  /// Toggle clip privacy
  void toggleClipPrivacy(String clipId) {
    if (myClips.value?.clips != null) {
      final clip = myClips.value!.clips!.firstWhere(
        (c) => c.sId == clipId,
        orElse: () => Clips(),
      );

      if (clip.sId != null) {
        clip.isPrivate = !(clip.isPrivate ?? false);
        myClips.refresh();

        // Update cache
        if (myClips.value != null) {
          _saveCache(myClips.value!);
        }
      }
    }
  }

  /// Clear all data (useful for logout)
  void clearData() {
    setMyClips(null);
    _clearCache();
    setRxRequestStatus(Status.COMPLETED);
    _lastRefresh = null;
  }

  /// Get clip by ID
  Clips? getClipById(String clipId) {
    return myClips.value?.clips?.firstWhere(
      (clip) => clip.sId == clipId,
      orElse: () => Clips(),
    );
  }

  /// Get total clips count
  int get totalClipsCount => myClips.value?.clips?.length ?? 0;

  /// Get public clips count
  int get publicClipsCount => publicClips.length;

  /// Get private clips count
  int get privateClipsCount => privateClips.length;

  @override
  void onClose() {
    // Don't clear cache on close, keep it for next session
    super.onClose();
  }
}
