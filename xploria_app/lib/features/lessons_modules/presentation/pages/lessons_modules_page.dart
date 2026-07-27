import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../auth/data/services/auth_storage_service.dart';
import '../../../content/domain/models/learning_module_model.dart';
import '../../../content/presentation/module_detail_screen.dart';
import '../../../dashboard/presentation/widgets/dashboard_shared_widgets.dart';
import '../../data/repositories/lessons_repository.dart';

class LessonsModulesPage extends StatefulWidget {
  const LessonsModulesPage({super.key});

  @override
  State<LessonsModulesPage> createState() => _LessonsModulesPageState();
}

class _LessonsModulesPageState extends State<LessonsModulesPage> {
  final LessonsRepository _repository = LessonsRepository();
  bool _isLoading = true;
  List<LearningModuleModel> _learningModules = [];
  int _selectedModuleCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final modules = await _repository.getLearningModules();
    if (mounted) {
      setState(() {
        _learningModules = modules;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = AuthStorageService().currentUser;

    final filteredModules = _learningModules.where((module) {
      if (_selectedModuleCategoryIndex == 0) return true; // Hot / Semua
      if (_selectedModuleCategoryIndex == 1) return module.stepsJson['level'] == 'Pemula';
      if (_selectedModuleCategoryIndex == 2) return module.stepsJson['level'] == 'Menengah';
      if (_selectedModuleCategoryIndex == 3) return module.isPremiumOnly == true;
      return true;
    }).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.textScalerOf(context).scale(236) + 24, 
            bottom: 120,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (filteredModules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: Text(
                        'Belum ada modul di kategori ini.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ...List.generate(filteredModules.length, (index) {
                  final module = filteredModules[index];
                  final userIsPremium = user?.isPremium ?? false;
                  final canAccess = !module.isPremiumOnly || userIsPremium;

                  return _buildColorfulModuleCard(
                    module: module,
                    index: index,
                    canAccess: canAccess,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ModuleDetailScreen(
                            module: module,
                            canAccess: canAccess,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WavyPageHeader(
            title: 'Lessons & Modules',
            subtitle: 'Pelajari koding & IoT dengan seru!',
            categoryPillsWidget: HeaderCategoryPills(
              categories: const ['Hot', 'Pemula', 'Menengah', 'VIP'],
              selectedIndex: _selectedModuleCategoryIndex,
              onSelect: (idx) {
                setState(() {
                  _selectedModuleCategoryIndex = idx;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorfulModuleCard({
    required LearningModuleModel module,
    required int index,
    required bool canAccess,
    required VoidCallback onTap,
  }) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF0A122C);
    final subColor = Colors.grey.shade600;

    final imageBgColor = module.imageBgColor != null
        ? Color(int.parse(module.imageBgColor!))
        : const Color(0xFFE0F2FE);

    return HoverCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: module.isPremiumOnly
                              ? const Color(0xFFFF9F1C)
                              : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          module.isPremiumOnly ? 'VIP' : 'FREE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: module.isPremiumOnly ? Colors.white : const Color(0xFF005CFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (module.stepsJson['level'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            module.stepsJson['level'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 110,
              height: 120,
              decoration: BoxDecoration(
                color: imageBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: module.imageAsset != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        module.imageAsset!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.smart_toy_rounded, size: 40, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
