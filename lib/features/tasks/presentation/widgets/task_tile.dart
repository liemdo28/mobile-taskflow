import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../shared/models/models.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool showProject;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.showProject = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Checkbox / priority
            _PriorityIndicator(priority: task.priority, isCompleted: task.isCompleted),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Project badge
                      if (showProject && task.projectName != null) ...[
                        _ProjectBadge(name: task.projectName!, color: task.projectColor ?? '#dc2626'),
                        const SizedBox(width: 8),
                      ],

                      // Section
                      if (task.sectionName != null) ...[
                        Icon(Icons.view_kanban_outlined, size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(task.sectionName!, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        const SizedBox(width: 8),
                      ],

                      // Due date
                      if (task.dueDate != null)
                        _DueBadge(dueDate: task.dueDate!, isCompleted: task.isCompleted),

                      // Assignee avatar
                      if (task.assigneeName != null) ...[
                        const Spacer(),
                        _AssigneeAvatar(name: task.assigneeName!, avatar: task.assigneeAvatar),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final String priority;
  final bool isCompleted;
  const _PriorityIndicator({required this.priority, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: 14, color: AppColors.success),
      );
    }

    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _color.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
      ),
    );
  }

  Color get _color {
    return {
      'urgent': AppColors.priorityUrgent,
      'high': AppColors.priorityHigh,
      'medium': AppColors.priorityMedium,
      'low': AppColors.priorityLow,
    }[priority] ?? AppColors.priorityLow;
  }
}

class _ProjectBadge extends StatelessWidget {
  final String name;
  final String color;
  const _ProjectBadge({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    Color c;
    try { c = Color(int.parse(color.replaceFirst('#', '0xFF'))); }
    catch (_) { c = AppColors.primary; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isCompleted;
  const _DueBadge({required this.dueDate, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colorKey = du.DateUtils.dueDateColor(dueDate, isCompleted);
    final bgColor = _bgColor(colorKey);
    final textColor = _textColor(colorKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            du.DateUtils.relativeDay(dueDate),
            style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _bgColor(String k) => {
    'overdue': AppColors.error.withOpacity(0.15),
    'today': const Color(0xFFFCA5A5).withOpacity(0.2),
    'soon': const Color(0xFFFDE047).withOpacity(0.15),
  }[k] ?? AppColors.bgTertiary;

  Color _textColor(String k) => {
    'overdue': AppColors.error,
    'today': const Color(0xFFDC2626),
    'soon': const Color(0xFFF59E0B),
  }[k] ?? AppColors.textTertiary;
}

class _AssigneeAvatar extends StatelessWidget {
  final String name;
  final String? avatar;
  const _AssigneeAvatar({required this.name, this.avatar});

  @override
  Widget build(BuildContext context) {
    return avatar != null
        ? CircleAvatar(radius: 10, backgroundImage: NetworkImage(avatar!))
        : CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
          );
  }
}