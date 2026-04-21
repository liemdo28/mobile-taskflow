import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/services/api_services.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('TaskFlow'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: dashboard.when(
        data: (data) => _DashboardContent(data: data),
        loading: () => _LoadingContent(),
        error: (e, _) => _ErrorContent(error: e, onRetry: () => ref.invalidate(dashboardProvider)),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardResult data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome
          Text(
            _greeting(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Stats cards
          _StatsGrid(stats: data.stats),

          const SizedBox(height: 24),

          // New tasks badge
          if (data.stats.newTasks > 0)
            _NewTasksBanner(count: data.stats.newTasks),

          // Upcoming
          if (data.upcomingTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Sắp đến hạn',
              subtitle: '${data.stats.dueToday} task hôm nay',
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả', style: TextStyle(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 8),
            ...data.upcomingTasks.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MiniTaskCard(task: t),
            )),
          ],

          // Recent
          if (data.recentTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Cập nhật gần đây'),
            const SizedBox(height: 8),
            ...data.recentTasks.take(5).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MiniTaskCard(task: t),
            )),
          ],

          if (data.upcomingTasks.isEmpty && data.recentTasks.isEmpty)
            _EmptyState(),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final name = 'bạn';
    if (hour < 12) return 'Chào buổi sáng, $name 👋';
    if (hour < 18) return 'Chào buổi chiều, $name 👋';
    return 'Chào buổi tối, $name 👋';
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.assignment_outlined,
          label: 'Tổng task',
          value: stats.totalTasks.toString(),
          color: AppColors.info,
        ),
        _StatCard(
          icon: Icons.today_outlined,
          label: 'Hôm nay',
          value: stats.dueToday.toString(),
          color: AppColors.warning,
        ),
        _StatCard(
          icon: Icons.warning_amber_rounded,
          label: 'Quá hạn',
          value: stats.overdue.toString(),
          color: AppColors.error,
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          label: 'Hoàn thành',
          value: stats.completedThisMonth.toString(),
          color: AppColors.success,
          subtitle: 'tháng này',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800, color: color,
          )),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _NewTasksBanner extends StatelessWidget {
  final int count;
  const _NewTasksBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('$count task mới', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Cần bạn xác nhận trước khi bắt đầu', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MiniTaskCard extends StatelessWidget {
  final Task task;
  const _MiniTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => TaskDetailPage(taskId: task.id),
      )),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            _priorityDot(task.priority),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (task.projectName != null)
                    Text(task.projectName!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (task.dueDate != null)
              _DueChip(dueDate: task.dueDate!, isCompleted: task.isCompleted),
          ],
        ),
      ),
    );
  }
}

class _priorityDot extends StatelessWidget {
  final String priority;
  const _priorityDot(this.priority);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: _color, shape: BoxShape.circle,
        border: Border.all(color: _color.withOpacity(0.4), width: 2),
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

class _DueChip extends StatelessWidget {
  final DateTime dueDate;
  final bool isCompleted;
  const _DueChip({required this.dueDate, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = du.DateUtils.dueDateColor(dueDate, isCompleted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor(color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        du.DateUtils.relativeDay(dueDate),
        style: TextStyle(color: _textColor(color), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _bgColor(String color) {
    return {
      'overdue': AppColors.error.withOpacity(0.15),
      'today': const Color(0xFFFCA5A5).withOpacity(0.2),
      'soon': const Color(0xFFFDE047).withOpacity(0.15),
    }[color] ?? AppColors.bgTertiary;
  }

  Color _textColor(String color) {
    return {
      'overdue': AppColors.error,
      'today': const Color(0xFFDC2626),
      'soon': const Color(0xFFF59E0B),
    }[color] ?? AppColors.textSecondary;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Chưa có task nào', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgTertiary,
      highlightColor: AppColors.bgElevated,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(height: 32, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorContent({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Không thể tải dashboard', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Thử lại'), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}