import 'package:go_router/go_router.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/plant_add_edit/plant_add_edit_screen.dart';
import 'screens/plant_detail/plant_detail_screen.dart';
import 'screens/stats/stats_screen.dart';
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
      path: '/plant/:plantId',
      name: 'plantDetail',
      builder: (context, state) =>
          PlantDetailScreen(plantId: state.pathParameters['plantId']!),
    ),
    GoRoute(
      path: '/plant/:plantId/edit',
      name: 'edit_plant', // Match the name used in goNamed
      builder: (context, state) =>
          PlantAddEditScreen(plantId: state.pathParameters['plantId']),
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
