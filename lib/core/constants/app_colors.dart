import 'package:flutter/material.dart';

/// TaskFlow color palette
/// Dark-first theme, giữ consistent với web PWA
class AppColors {
  // Brand
  static const Color primary       = Color(0xFFDC2626);
  static const Color primaryDark   = Color(0xFF991B1B);
  static const Color primaryLight  = Color(0xFFFCA5A5);

  // Dark theme (default)
  static const Color bgPrimary     = Color(0xFF09090B);
  static const Color bgSecondary   = Color(0xFF18181B);
  static const Color bgTertiary    = Color(0xFF27272A);
  static const Color bgCard        = Color(0xFF1C1C1E);
  static const Color bgElevated    = Color(0xFF2C2C2E);

  // Light theme
  static const Color bgLightPrimary   = Color(0xFFFFFFFF);
  static const Color bgLightSecondary = Color(0xFFF4F4F5);
  static const Color bgLightTertiary  = Color(0xFFE4E4E7);
  static const Color bgLightCard       = Color(0xFFFFFFFF);
  static const Color bgLightElevated   = Color(0xFFF9FAFB);

  // Text
  static const Color textPrimary   = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary  = Color(0xFF71717A);
  static const Color textDisabled  = Color(0xFF52525B);
  static const Color textLightPrimary   = Color(0xFF18181B);
  static const Color textLightSecondary = Color(0xFF71717A);

  // Priority colors
  static const Color priorityUrgent = Color(0xFFDC2626);
  static const Color priorityHigh    = Color(0xFFF59E0B);
  static const Color priorityMedium  = Color(0xFF3B82F6);
  static const Color priorityLow     = Color(0xFF71717A);

  // Status colors
  static const Color statusTodo       = Color(0xFF71717A);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusReview     = Color(0xFFF59E0B);
  static const Color statusDone       = Color(0xFF22C55E);

  // Utility
  static const Color success    = Color(0xFF22C55E);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color error      = Color(0xFFEF4444);
  static const Color info       = Color(0xFF3B82F6);
  static const Color divider    = Color(0xFF27272A);
  static const Color border     = Color(0xFF3F3F46);
  static const Color shimmer    = Color(0xFF27272A);
}

/// Priority utilities
class PriorityUtils {
  static String label(String priority) {
    return switch (priority) {
      'urgent' => 'Khẩn cấp',
      'high' => 'Cao',
      'medium' => 'Trung bình',
      'low' => 'Thấp',
      _ => priority,
    };
  }

  static Color color(String priority) {
    return switch (priority) {
      'urgent' => AppColors.priorityUrgent,
      'high' => AppColors.priorityHigh,
      'medium' => AppColors.priorityMedium,
      'low' => AppColors.priorityLow,
      _ => AppColors.priorityLow,
    };
  }

  static const List<String> all = ['urgent', 'high', 'medium', 'low'];
}

/// Status utilities
class StatusUtils {
  static String label(String status) {
    return switch (status) {
      'todo' => 'To Do',
      'in_progress' => 'Đang làm',
      'review' => 'Review',
      'done' => 'Hoàn thành',
      _ => status,
    };
  }

  static Color color(String status) {
    return switch (status) {
      'todo' => AppColors.statusTodo,
      'in_progress' => AppColors.statusInProgress,
      'review' => AppColors.statusReview,
      'done' => AppColors.statusDone,
      _ => AppColors.textTertiary,
    };
  }

  static const List<String> all = ['todo', 'in_progress', 'review', 'done'];
}