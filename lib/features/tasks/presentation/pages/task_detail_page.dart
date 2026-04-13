import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final int taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final commentsAsync = ref.watch(taskCommentsProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showActions(context)),
        ],
      ),
      body: taskAsync.when(
        data: (task) => _TaskDetailContent(
          task: task,
          commentsAsync: commentsAsync,
          commentController: _commentController,
          isSubmitting: _isSubmittingComment,
          onSubmitComment: () => _submitComment(task.id),
          onStatusChanged: (status) => _changeStatus(task.id, status),
          onRefresh: () {
            ref.invalidate(taskDetailProvider(widget.taskId));
            ref.invalidate(taskCommentsProvider(widget.taskId));
          },
        ),
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Error: $e', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'),
                onPressed: () => ref.invalidate(taskDetailProvider(widget.taskId))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitComment(int taskId) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmittingComment = true);
    try {
      await ref.read(apiServiceProvider).addComment(taskId, content);
      _commentController.clear();
      ref.invalidate(taskCommentsProvider(taskId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _changeStatus(int taskId, String status) async {
    try {
      await ref.read(apiServiceProvider).changeTaskStatus(taskId, status);
      ref.invalidate(taskDetailProvider(taskId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit Task'), onTap: () {}),
            ListTile(leading: const Icon(Icons.check_circle_outline), title: const Text('Mark Complete'), onTap: () {}),
            ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: const Text('Delete', style: TextStyle(color: AppColors.error)), onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _TaskDetailContent extends StatelessWidget {
  final Task task;
  final AsyncValue<List<Comment>> commentsAsync;
  final TextEditingController commentController;
  final bool isSubmitting;
  final VoidCallback onSubmitComment;
  final void Function(String) onStatusChanged;
  final VoidCallback onRefresh;

  const _TaskDetailContent({
    required this.task,
    required this.commentsAsync,
    required this.commentController,
    required this.isSubmitting,
    required this.onSubmitComment,
    required this.onStatusChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                Text(task.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                // Status + Priority row
                Wrap(
                  spacing: 8,
                  children: [
                    _StatusChip(status: task.status, onTap: () => _showStatusPicker(context)),
                    _PriorityChip(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(task.description!, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 20),
                ],

                // Info fields
                _InfoRow(icon: Icons.folder_outlined, label: 'Project', value: task.projectName ?? '—'),
                _InfoRow(icon: Icons.view_kanban_outlined, label: 'Section', value: task.sectionName ?? '—'),
                if (task.assigneeName != null)
                  _InfoRow(icon: Icons.person_outline, label: 'Assigned to', value: task.assigneeName!),
                if (task.creatorName != null)
                  _InfoRow(icon: Icons.person_add_outlined, label: 'Created by', value: task.creatorName!),
                if (task.dueDate != null)
                  _InfoRow(icon: Icons.event_outlined, label: 'Due date',
                    value: du.DateUtils.relativeDay(task.dueDate!)),
                _InfoRow(icon: Icons.flag_outlined, label: 'Priority', value: PriorityUtils.label(task.priority)),

                const SizedBox(height: 24),

                // Comments
                const Text('Bình luận', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                commentsAsync.when(
                  data: (comments) => comments.isEmpty
                      ? Text('Chưa có bình luận', style: TextStyle(color: AppColors.textTertiary, fontSize: 13))
                      : Column(
                          children: comments.map((c) => _CommentTile(comment: c)).toList(),
                        ),
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  )),
                  error: (e, _) => Text('Error loading comments', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),

        // Comment input
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: const BoxDecoration(color: AppColors.bgSecondary, border: Border(top: BorderSide(color: AppColors.divider))),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmitComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Icon(Icons.send_rounded, color: AppColors.primary),
                onPressed: isSubmitting ? null : onSubmitComment,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Đổi trạng thái', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            ...StatusUtils.all.map((s) => ListTile(
              leading: _statusIcon(s),
              title: Text(StatusUtils.label(s)),
              trailing: task.status == s ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                Navigator.pop(ctx);
                onStatusChanged(s);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    final color = {
      'todo': AppColors.statusTodo,
      'in_progress': AppColors.statusInProgress,
      'review': AppColors.statusReview,
      'done': AppColors.statusDone,
    }[status] ?? AppColors.textTertiary;
    final icon = {
      'todo': Icons.radio_button_unchecked,
      'in_progress': Icons.play_arrow_rounded,
      'review': Icons.rate_review_outlined,
      'done': Icons.check_circle,
    }[status] ?? Icons.help_outline;
    return Icon(icon, color: color, size: 22);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final VoidCallback onTap;
  const _StatusChip({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = {
      'todo': AppColors.statusTodo,
      'in_progress': AppColors.statusInProgress,
      'review': AppColors.statusReview,
      'done': AppColors.statusDone,
    }[status] ?? AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(StatusUtils.label(status), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = {
      'urgent': AppColors.priorityUrgent,
      'high': AppColors.priorityHigh,
      'medium': AppColors.priorityMedium,
      'low': AppColors.priorityLow,
    }[priority] ?? AppColors.priorityLow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(PriorityUtils.label(priority), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text('$label:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              (comment.userName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(
                      du.DateUtils.timeAgo(comment.createdAt),
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}