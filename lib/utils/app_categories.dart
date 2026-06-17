import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Color softColor;

  const AppCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.softColor,
  });
}

class AppCategories {
  AppCategories._();

  static const all = <AppCategory>[
    AppCategory(
      id: 'general',
      label: 'General',
      icon: Icons.bookmark_outline,
      color: ZyvoraColors.primary,
      softColor: ZyvoraColors.primarySoft,
    ),
    AppCategory(
      id: 'work',
      label: 'Work',
      icon: Icons.work_outline,
      color: ZyvoraColors.purple,
      softColor: ZyvoraColors.purpleSoft,
    ),
    AppCategory(
      id: 'study',
      label: 'Study',
      icon: Icons.menu_book_outlined,
      color: ZyvoraColors.cyan,
      softColor: ZyvoraColors.cyanSoft,
    ),
    AppCategory(
      id: 'health',
      label: 'Health',
      icon: Icons.favorite_outline,
      color: ZyvoraColors.red,
      softColor: ZyvoraColors.redSoft,
    ),
    AppCategory(
      id: 'finance',
      label: 'Finance',
      icon: Icons.payments_outlined,
      color: ZyvoraColors.green,
      softColor: ZyvoraColors.greenSoft,
    ),
    AppCategory(
      id: 'home',
      label: 'Home',
      icon: Icons.home_outlined,
      color: ZyvoraColors.coral,
      softColor: ZyvoraColors.coralSoft,
    ),
    AppCategory(
      id: 'errand',
      label: 'Errand',
      icon: Icons.shopping_bag_outlined,
      color: ZyvoraColors.yellow,
      softColor: ZyvoraColors.yellowSoft,
    ),
  ];

  static AppCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
