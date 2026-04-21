import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';

class CreateTaskPage extends ConsumerStatefulWidget {
  const CreateTaskPage({super.key});

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _selectedProjectId;
  int? _selectedAssigneeId;
  int? _selectedSectionId;
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn project')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(apiServiceProvider).createTask(
        projectId: _selectedProjectId!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        assigneeId: _selectedAssigneeId,
        sectionId: _selectedSectionId,
        priority: _priority,
        dueDate: _dueDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo task thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Task'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Tạo'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                hintText: 'Nhập tiêu đề task...',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Tiêu đề là bắt buộc' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Nhập mô tả chi tiết...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Project picker
            _SectionLabel('Project *'),
            projects.when(
              data: (list) => _ProjectPicker(
                projects: list,
                selectedId: _selectedProjectId,
                onChanged: (id) => setState(() {
                  _selectedProjectId = id;
                  _selectedSectionId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e', style: TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 16),

            // Section picker (nếu đã chọn project)
            if (_selectedProjectId != null) ...[
              _SectionLabel('Section'),
              _SectionPicker(
                projectId: _selectedProjectId!,
                selectedId: _selectedSectionId,
                onChanged: (id) => setState(() => _selectedSectionId = id),
              ),
              const SizedBox(height: 16),
            ],

            // Assignee
            _SectionLabel('Người thực hiện'),
            users.when(
              data: (list) => _AssigneePicker(
                users: list,
                selectedId: _selectedAssigneeId,
                onChanged: (id) => setState(() => _selectedAssigneeId = id),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // Due date
            _SectionLabel('Ngày hết hạn'),
            _DueDatePicker(
              value: _dueDate,
              onChanged: (d) => setState(() => _dueDate = d),
            ),
            const SizedBox(height: 20),

            // Priority
            _SectionLabel('Độ ưu tiên'),
            _PriorityPicker(
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}

class _ProjectPicker extends StatelessWidget {
  final List<Project> projects;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  const _ProjectPicker({required this.projects, this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: projects.map((p) {
        final isSelected = p.id == selectedId;
        Color c;
        try { c = Color(int.parse(p.color.replaceFirst('#', '0xFF'))); }
        catch (_) { c = AppColors.primary; }

        return GestureDetector(
          onTap: () => onChanged(p.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? c.withOpacity(0.15) : AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: c) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(p.name, style: TextStyle(color: isSelected ? c : AppColors.textPrimary, fontSize: 13)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionPicker extends ConsumerWidget {
  final int projectId;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _SectionPicker({required this.projectId, this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Không có'),
          selected: selectedId == null,
          onSelected: (_) => onChanged(null),
        ),
      ],
    );
  }
}

class _AssigneePicker extends StatelessWidget {
  final List<User> users;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _AssigneePicker({required this.users, this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: users.map((u) {
        final isSelected = u.id == selectedId;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : u.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? const BorderSide(color: AppColors.primary) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(u.name[0].toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                const SizedBox(width: 8),
                Text(u.name, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontSize: 13)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DueDatePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DueDatePicker({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (date != null) onChanged(date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    value != null
                        ? '${value!.day}/${value!.month}/${value!.year}'
                        : 'Chọn ngày hết hạn',
                    style: TextStyle(color: value != null ? AppColors.textPrimary : AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () => onChanged(null),
          ),
        ],
      ],
    );
  }
}

class _PriorityPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PriorityPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _PriorityChip(label: 'Thấp', priority: 'low', isSelected: value == 'low', onTap: () => onChanged('low')),
        _PriorityChip(label: 'Trung bình', priority: 'medium', isSelected: value == 'medium', onTap: () => onChanged('medium')),
        _PriorityChip(label: 'Cao', priority: 'high', isSelected: value == 'high', onTap: () => onChanged('high')),
        _PriorityChip(label: 'Khẩn cấp', priority: 'urgent', isSelected: value == 'urgent', onTap: () => onChanged('urgent')),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final String priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityChip({required this.label, required this.priority, required this.isSelected, required this.onTap});

  Color get _color => {
    'urgent': AppColors.priorityUrgent,
    'high': AppColors.priorityHigh,
    'medium': AppColors.priorityMedium,
    'low': AppColors.priorityLow,
  }[priority] ?? AppColors.priorityLow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.15) : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: _color) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? _color : AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
