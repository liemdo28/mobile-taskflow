import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';

class MyTasksPage extends ConsumerWidget {
  const MyTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTasks = ref.watch(myTasksProvider);
    final group = ref.watch(myTasksGroupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.invalidate(myTasksProvider)),
        ],
      ),
      body: Column(
        children: [
          // Group chips
          _GroupChips(group: group, onChanged: (g) => ref.read(myTasksGroupProvider.notifier).state = g),

          // Task list
          Expanded(
            child: myTasks.when(
              data: (result) => _TaskList(result: result),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(height: 8),
                    Text('Error: $e', style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'),
                      onPressed: () => ref.invalidate(myTasksProvider)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChips extends StatelessWidget {
  final String group;
  final ValueChanged<String> onChanged;

  const _GroupChips({required this.group, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final groups = [
      ('all', 'Tất cả'),
      ('today', 'Hôm nay'),
      ('upcoming', 'Sắp tới'),
      ('overdue', 'Quá hạn'),
      ('completed', 'Đã xong'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: groups.map((g) {
            final isSelected = g.$1 == group;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(g.$2),
                selected: isSelected,
                onSelected: (_) => onChanged(g.$1),
                backgroundColor: AppColors.bgTertiary,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: isSelected ? const BorderSide(color: AppColors.primary) : BorderSide.none,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final MyTasksResult result;
  const _TaskList({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text('Không có task nào', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: result.tasks.length,
        itemBuilder: (context, i) {
          final task = result.tasks[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskTile(
              task: task,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => TaskDetailPage(taskId: task.id),
              )),
            ),
          );
        },
      ),
    );
  }
}
