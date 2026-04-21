import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: auth.user?.avatar != null
                      ? ClipOval(child: Image.network(auth.user!.avatar!, width: 88, height: 88, fit: BoxFit.cover))
                      : Text(
                          (auth.user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                ),
                const SizedBox(height: 12),
                Text(auth.user?.name ?? 'User', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(auth.user?.email ?? '', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Settings sections
          _SectionTitle('Tài khoản'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Cập nhật profile',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _SectionTitle('Ứng dụng'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            trailing: Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(themeModeProvider);
                return Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light,
                  activeColor: AppColors.primary,
                );
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _SectionTitle('Khác'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Về TaskFlow',
            subtitle: 'v1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _showLogoutDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 22, color: AppColors.textSecondary),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
