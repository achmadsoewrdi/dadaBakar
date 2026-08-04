import 'package:flutter/material.dart';
import '../../../dashboard/data/repositories/dashboard_repository.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/models/project_model.dart';
import '../../../blockly_workspace/presentation/pages/blockly_workspace_screen.dart';
import '../../data/data_sources/project_category_service.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final DashboardRepository _repository = DashboardRepository();
  final ProjectCategoryService _categoryService = ProjectCategoryService();
  
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _filteredProjects = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _categoryService.init();
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _repository.getRecentProjects();
    if (mounted) {
      setState(() {
        _allProjects = projects;
        _isLoading = false;
        _filterProjects();
      });
    }
  }

  void _filterProjects() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredProjects = List.from(_allProjects);
      } else {
        _filteredProjects = _allProjects.where((p) {
          final cat = _categoryService.getCategoryForProject(p.id);
          return cat == _selectedCategory;
        }).toList();
      }
    });
  }

  Future<void> _addNewProject(String name, String category) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );
    try {
      final repo = ProjectRepositoryImpl();
      final newProj = await repo.createProject(name); 
      await _categoryService.setProjectCategory(newProj.id, category);
      
      if (mounted) Navigator.pop(context); 
      
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocklyWorkspaceScreen(project: newProj),
          ),
        );
        _initData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat proyek: $e')));
      }
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Proyek'),
        content: Text('Yakin ingin menghapus proyek "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final repo = ProjectRepositoryImpl();
        await repo.deleteProject(project.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proyek berhasil dihapus')),
          );
        }
        _initData();
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus proyek: $e')),
          );
        }
      }
    }
  }

  void _confirmDeleteCategory(String category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Anda yakin ingin menghapus kategori "$category"? Proyek di dalamnya akan masuk ke "All".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _categoryService.deleteCategory(category);
      if (_selectedCategory == category) {
        _selectedCategory = 'All';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori "$category" dihapus')),
        );
        _initData();
      }
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    String selectedIcon = 'assets/images/modules/project/robot.png';
    final List<String> availableIcons = [
      'assets/images/modules/project/plant.png',
      'assets/images/modules/project/robot.png',
      'assets/images/modules/project/camera.png',
      'assets/images/modules/project/term.png',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Category Name'),
                ),
                const SizedBox(height: 16),
                const Text('Select Category Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableIcons.map((iconPath) {
                    final isSelected = selectedIcon == iconPath;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = iconPath),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F0FE) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF005CFF) : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(iconPath, width: 40, height: 40, fit: BoxFit.contain),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await _categoryService.addCategory(controller.text.trim(), selectedIcon);
                    if (mounted) {
                      setState(() {});
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCreateProjectDialog() {
    final TextEditingController controller = TextEditingController();
    String selectedCat = 'Agriculture';
    if (_categoryService.categories.isNotEmpty) {
      selectedCat = _categoryService.categories.first;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create New Project'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Project Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  items: _categoryService.categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCat = val);
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(context);
                    _addNewProject(controller.text.trim(), selectedCat);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        }
      ),
    );
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7) return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0) return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0) return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Just now";
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Build categories list (All + custom categories + Add)
    final displayCategories = ['All', ..._categoryService.categories];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Projects',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    icon: Icon(
                      _isEditMode ? Icons.check_circle_rounded : Icons.edit_rounded,
                      size: 20,
                      color: _isEditMode ? Colors.green : const Color(0xFF005CFF),
                    ),
                    label: Text(
                      _isEditMode ? 'Done' : 'Edit',
                      style: TextStyle(
                        color: _isEditMode ? Colors.green : const Color(0xFF005CFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category Selector
            Container(
              height: 110,
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: ListView.builder(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: displayCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == displayCategories.length) {
                    // Add Button
                    return GestureDetector(
                      onTap: _showAddCategoryDialog,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.grey.shade500),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final cat = displayCategories[index];
                  final isSelected = cat == _selectedCategory;
                  
                  IconData catIcon = Icons.dashboard;
                  if (cat == 'All') {
                    catIcon = Icons.grid_view_rounded;
                  } else {
                    final iconPath = _categoryService.getIconForCategory(cat);
                    if (iconPath.contains('plant')) catIcon = Icons.eco;
                    else if (iconPath.contains('robot')) catIcon = Icons.smart_toy_rounded;
                    else if (iconPath.contains('camera')) catIcon = Icons.camera_alt_rounded;
                    else if (iconPath.contains('term')) catIcon = Icons.thermostat_rounded;
                  }
                  
                  return DragTarget<ProjectModel>(
                    onAcceptWithDetails: (details) async {
                      final draggedProject = details.data;
                      if (cat != 'All' && _categoryService.getCategoryForProject(draggedProject.id) != cat) {
                        await _categoryService.setProjectCategory(draggedProject.id, cat);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${draggedProject.name} moved to $cat')),
                          );
                          _initData(); 
                        }
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            _filterProjects();
                          });
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: index == displayCategories.length - 1 ? 0 : 12),
                              width: 70,
                              decoration: BoxDecoration(
                                color: isHovered ? const Color(0xFFE8F0FE) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected || isHovered
                                    ? Border.all(color: const Color(0xFF005CFF), width: 2)
                                    : Border.all(color: Colors.transparent, width: 2),
                                boxShadow: [
                                  if (!isSelected && !isHovered)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    catIcon, 
                                    color: (isSelected || isHovered) ? const Color(0xFF005CFF) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: (isSelected || isHovered) ? FontWeight.bold : FontWeight.normal,
                                      color: (isSelected || isHovered) ? const Color(0xFF005CFF) : Colors.grey.shade800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      height: 3,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF005CFF),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_isEditMode && cat != 'All')
                              Positioned(
                                top: -4,
                                right: index == displayCategories.length - 1 ? -4 : 8,
                                child: GestureDetector(
                                  onTap: () {
                                    _confirmDeleteCategory(cat);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Hero Banner
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COLLECTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'All Projects',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A122C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage all your IoT\ncreations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Project List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredProjects.length + 1,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == _filteredProjects.length) {
                    // Dashed create button at the bottom
                    return GestureDetector(
                      onTap: _showCreateProjectDialog,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF005CFF),
                            width: 1,
                            style: BorderStyle.solid, 
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Color(0xFF005CFF)),
                            SizedBox(width: 8),
                            Text(
                              'Create New Project',
                              style: TextStyle(
                                color: Color(0xFF005CFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final project = _filteredProjects[index];
                  final isFavorite = index == 0; // Just mock favorite for demo based on UI

                  Widget projectCardWidget = Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_isEditMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.drag_indicator_rounded, color: Colors.grey.shade400),
                          ),
                        Image.asset(
                          _categoryService.getIconForCategory(_categoryService.getCategoryForProject(project.id)),
                          width: _isEditMode ? 50 : 60,
                          height: _isEditMode ? 50 : 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      project.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A122C),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isFavorite && !_isEditMode)
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last edited ${_timeAgo(project.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isEditMode)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () => _deleteProject(project),
                          )
                        else
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (String newCategory) async {
                              await _categoryService.setProjectCategory(project.id, newCategory);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Project moved to $newCategory')),
                                );
                                _initData();
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return _categoryService.categories.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text('Move to $choice'),
                                );
                              }).toList();
                            },
                          ),
                      ],
                    ),
                  );

                  if (_isEditMode) {
                    return LongPressDraggable<ProjectModel>(
                      data: project,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.8,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 48,
                            child: projectCardWidget,
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: projectCardWidget,
                      ),
                      child: projectCardWidget,
                    );
                  }

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocklyWorkspaceScreen(project: project),
                        ),
                      );
                      _initData();
                    },
                    child: projectCardWidget,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
