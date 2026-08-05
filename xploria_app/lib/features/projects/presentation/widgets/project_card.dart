import 'package:flutter/material.dart';
import '../../domain/models/project_model.dart';
import '../../data/data_sources/project_category_service.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final bool isEditMode;
  final bool isFavorite;
  final VoidCallback? onDelete;
  final Function(String)? onCategorySelected;
  final ProjectCategoryService categoryService;
  final bool showChevron; // For dashboard view
  final bool showPopupMenu; // For project list view

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.categoryService,
    this.isEditMode = false,
    this.isFavorite = false,
    this.onDelete,
    this.onCategorySelected,
    this.showChevron = false,
    this.showPopupMenu = false,
  });

  String _timeAgo(DateTime? date) {
    if (date == null) return 'unknown';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.drag_indicator_rounded, color: Colors.grey.shade400),
              ),
            Image.asset(
              categoryService.getIconForCategory(categoryService.getCategoryForProject(project.id)),
              width: isEditMode ? 50 : 60,
              height: isEditMode ? 50 : 60,
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
                      if (isFavorite && !isEditMode)
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Last edited ${_timeAgo(project.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (project.blynkConfigJson != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005CFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'IoT Lab',
                            style: TextStyle(fontSize: 10, color: Color(0xFF005CFF), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isEditMode && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: onDelete,
              )
            else if (showPopupMenu && onCategorySelected != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: onCategorySelected,
                itemBuilder: (BuildContext context) {
                  return categoryService.categories.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text('Move to $choice'),
                    );
                  }).toList();
                },
              )
            else if (showChevron)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
