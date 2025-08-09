import 'package:go_router/go_router.dart';

import 'screens/dashboard/widgets/dashboard_screen.dart';
import 'screens/plant_add_edit/plant_add_edit_screen.dart';
import 'screens/plant_detail/plant_detail_screen.dart';
import 'screens/stats/widgets/stats_screen.dart';
import 'screens/settings/notification_settings_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/plant/add',
      name: 'addPlant',
      builder: (context, state) => const PlantAddEditScreen(),
    ),
    GoRoute(
      path: '/plant/:id',
      name: 'plantDetail',
      builder:
          (context, state) =>
              PlantDetailScreen(plantId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/plant/:id/edit',
      name: 'editPlant',
      builder:
          (context, state) =>
              PlantAddEditScreen(plantId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/stats',
      name: 'stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
  ],
);
