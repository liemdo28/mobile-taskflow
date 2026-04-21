import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers.dart';
import 'dashboard_page.dart';
import 'my_tasks_page.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../inbox/presentation/pages/inbox_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardPage(),
    MyTasksPage(),
    CalendarPage(),
    InboxPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          const NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box_rounded),
            label: AppStrings.navMyTasks,
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: AppStrings.navCalendar,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (unreadCount.valueOrNull ?? 0) > 0,
              label: Text('${unreadCount.valueOrNull ?? 0}'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: (unreadCount.valueOrNull ?? 0) > 0,
              label: Text('${unreadCount.valueOrNull ?? 0}'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.inbox_rounded),
            ),
            label: AppStrings.navInbox,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}