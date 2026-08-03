import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProjectCategoryService {
  static final ProjectCategoryService _instance = ProjectCategoryService._internal();
  factory ProjectCategoryService() => _instance;
  ProjectCategoryService._internal();

  final _storage = const FlutterSecureStorage();
  static const _categoriesKey = 'project_categories';
  static const _categoryIconMapKey = 'project_category_icon_map';
  static const _projectCategoryMapKey = 'project_category_map';

  List<String> _categories = ['Agriculture', 'Robotics'];
  
  // Category Name -> Asset Image Path
  Map<String, String> _categoryIconMap = {
    'Agriculture': 'assets/images/modules/project/plant.png',
    'Robotics': 'assets/images/modules/project/robot.png',
  };

  Map<String, String> _projectCategoryMap = {}; // projectId -> categoryName

  List<String> get categories => _categories;

  Future<void> init() async {
    final catStr = await _storage.read(key: _categoriesKey);
    if (catStr != null) {
      final decoded = jsonDecode(catStr) as List;
      _categories = decoded.map((e) => e.toString()).toList();
    }

    final catIconStr = await _storage.read(key: _categoryIconMapKey);
    if (catIconStr != null) {
      _categoryIconMap = Map<String, String>.from(jsonDecode(catIconStr));
    }

    final mapStr = await _storage.read(key: _projectCategoryMapKey);
    if (mapStr != null) {
      _projectCategoryMap = Map<String, String>.from(jsonDecode(mapStr));
    }
  }

  Future<void> addCategory(String category, String iconPath) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      await _storage.write(key: _categoriesKey, value: jsonEncode(_categories));
    }
    _categoryIconMap[category] = iconPath;
    await _storage.write(key: _categoryIconMapKey, value: jsonEncode(_categoryIconMap));
  }

  String getIconForCategory(String category) {
    return _categoryIconMap[category] ?? 'assets/images/modules/project/robot.png';
  }

  Future<void> setProjectCategory(String projectId, String category) async {
    _projectCategoryMap[projectId] = category;
    await _storage.write(key: _projectCategoryMapKey, value: jsonEncode(_projectCategoryMap));
  }

  Future<void> deleteCategory(String category) async {
    _categories.remove(category);
    _categoryIconMap.remove(category);
    _projectCategoryMap.removeWhere((key, value) => value == category);
    await _storage.write(key: _categoriesKey, value: jsonEncode(_categories));
    await _storage.write(key: _categoryIconMapKey, value: jsonEncode(_categoryIconMap));
    await _storage.write(key: _projectCategoryMapKey, value: jsonEncode(_projectCategoryMap));
  }

  String getCategoryForProject(String projectId) {
    if (_projectCategoryMap.containsKey(projectId)) {
      final cat = _projectCategoryMap[projectId]!;
      if (_categories.contains(cat)) return cat;
    }
    return _categories.isNotEmpty ? _categories.first : 'All';
  }
}
