// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/plant_add_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/notification_settings_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/plant/add',
      builder: (context, state) => const PlantAddScreen(),
    ),
    GoRoute(
      path: '/plant/:id',
      builder: (context, state) => PlantDetailScreen(id: state.params['id']!),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
  ],
);
