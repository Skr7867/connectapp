import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum FileTypeFormat { media, link, document, other }

class LocalFileManager {
  static const String _storageKeyPrefix = 'local_files_';

  LocalFileManager._privateConstructor();

  static final LocalFileManager _instance =
      LocalFileManager._privateConstructor();

  factory LocalFileManager() => _instance;

  // Internal cache: userId -> (FileTypeFormat -> List<String>)
  final Map<String, Map<FileTypeFormat, List<String>>> _userFilePaths = {};

  String? _currentUserId;

  // Call this to update which userId to track
  Future<void> updateCurrentUserId(String userId) async {
    if (userId != _currentUserId) {
      _currentUserId = userId;
      await _loadUserFiles(userId);
    }
  }

  // Throws if no userId set and none provided
  void _ensureUserId(String? userId) {
    if (userId == null && _currentUserId == null) {
      throw Exception(
          'No userId provided or set as current. Call updateCurrentUserId first or provide userId.');
    }
  }

  Future<List<String>> getFilePaths(FileTypeFormat type,
      {String? userId}) async {
    _ensureUserId(userId);
    final id = userId ?? _currentUserId!;
    if (!_userFilePaths.containsKey(id)) {
      await _loadUserFiles(id);
    }
    return UnmodifiableListView(_userFilePaths[id]?[type] ?? []);
  }

  Future<void> addFilePath(FileTypeFormat type, String path,
      {String? userId}) async {
    _ensureUserId(userId);
    final id = userId ?? _currentUserId!;
    if (!_userFilePaths.containsKey(id)) {
      await _loadUserFiles(id);
    }
    final list = _userFilePaths[id]?[type];
    if (list == null) {
      _userFilePaths[id] = {for (var ft in FileTypeFormat.values) ft: []};
      _userFilePaths[id]![type]?.add(path);
    } else if (!list.contains(path)) {
      list.add(path);
    } else {
      return;
    }
    await _save(id, type);
  }

  Future<void> addFilePaths(FileTypeFormat type, List<String> paths,
      {String? userId}) async {
    _ensureUserId(userId);
    final id = userId ?? _currentUserId!;
    if (!_userFilePaths.containsKey(id)) {
      await _loadUserFiles(id);
    }
    var list = _userFilePaths[id]?[type];
    if (list == null) {
      _userFilePaths[id] = {for (var ft in FileTypeFormat.values) ft: []};
      list = _userFilePaths[id]![type];
    }
    bool added = false;
    for (var path in paths) {
      if (!list!.contains(path)) {
        list.add(path);
        added = true;
      }
    }
    if (added) {
      await _save(id, type);
    }
  }

  Future<void> clearFilePaths({FileTypeFormat? type, String? userId}) async {
    _ensureUserId(userId);
    final id = userId ?? _currentUserId!;
    final prefs = await SharedPreferences.getInstance();
    if (!_userFilePaths.containsKey(id)) {
      return;
    }
    if (type != null) {
      _userFilePaths[id]?[type]?.clear();
      await prefs.remove(_makeKey(id, type));
    } else {
      for (var t in FileTypeFormat.values) {
        _userFilePaths[id]?[t]?.clear();
        await prefs.remove(_makeKey(id, t));
      }
    }
  }

  Future<bool> hasFiles(FileTypeFormat type, {String? userId}) async {
    _ensureUserId(userId);
    final id = userId ?? _currentUserId!;
    if (!_userFilePaths.containsKey(id)) {
      await _loadUserFiles(id);
    }
    return (_userFilePaths[id]?[type]?.isNotEmpty ?? false);
  }

  Future<void> _loadUserFiles(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = <FileTypeFormat, List<String>>{};
    for (var type in FileTypeFormat.values) {
      final key = _makeKey(userId, type);
      final savedData = prefs.getString(key);
      if (savedData != null) {
        try {
          final decoded = jsonDecode(savedData) as List<dynamic>;
          userMap[type] = decoded.cast<String>().toList();
        } catch (e) {
          await prefs.remove(key);
          userMap[type] = [];
        }
      } else {
        userMap[type] = [];
      }
    }
    _userFilePaths[userId] = userMap;
  }

  Future<void> _save(String userId, FileTypeFormat type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _makeKey(userId, type);
    final list = _userFilePaths[userId]?[type] ?? [];
    await prefs.setString(key, jsonEncode(list));
  }

  String _makeKey(String userId, FileTypeFormat type) {
    return '$_storageKeyPrefix${userId}_${type.toString()}';
  }
}
