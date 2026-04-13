import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(calendarProvider);
    final month = ref.watch(calendarMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_monthLabel()),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: calendar.when(
        data: (days) => _CalendarContent(
          days: days,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e', style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 12),
              ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'),
                onPressed: () => ref.invalidate(calendarProvider)),
            ],
          ),
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
    ref.read(calendarMonthProvider.notifier).state = _focusedMonth;
  }

  String _monthLabel() {
    const months = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
                    'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];
    return '${months[_focusedMonth.month - 1]}, ${_focusedMonth.year}';
  }
}

class _CalendarContent extends StatelessWidget {
  final List<CalendarDay> days;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarContent({
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tasksOnSelected = selectedDate != null
        ? days.where((d) => d.date == _dateStr(selectedDate!)).expand((d) => d.tasks).toList()
        : <Task>[];

    return Column(
      children: [
        // Weekday header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ['CN','T2','T3','T4','T5','T6','T7'].map((d) =>
              Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))))
            ).toList(),
          ),
        ),

        // Calendar grid
        Expanded(
          flex: 2,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final isToday = day.isToday;
              final isSelected = selectedDate != null && _dateStr(DateTime(
                int.parse(day.date.split('-')[0]),
                int.parse(day.date.split('-')[1]),
                int.parse(day.date.split('-')[2]),
              )) == day.date;
              final isOverdue = day.isOverdue;
              final hasTasks = day.tasksCount > 0;

              return GestureDetector(
                onTap: () => onDateSelected(DateTime(
                  int.parse(day.date.split('-')[0]),
                  int.parse(day.date.split('-')[1]),
                  int.parse(day.date.split('-')[2]),
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary
                        : isToday ? AppColors.primary.withOpacity(0.15)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white
                              : isOverdue && !isToday ? AppColors.error
                              : AppColors.textPrimary,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                      if (hasTasks)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white
                                : isOverdue ? AppColors.error
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Tasks on selected day
        Expanded(
          flex: 2,
          child: selectedDate == null
              ? Center(child: Text('Chọn ngày để xem task', style: TextStyle(color: AppColors.textSecondary)))
              : tasksOnSelected.isEmpty
                  ? Center(child: Text('Không có task ngày này', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tasksOnSelected.length,
                      itemBuilder: (context, i) {
                        final task = tasksOnSelected[i];
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
        ),
      ],
    );
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}
