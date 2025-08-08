import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/plant_add_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/notification_setting_screen.dart';

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
      builder: (context, state) => const PlantAddScreen(),
    ),
    GoRoute(
      path: '/plant/:id',
      name: 'plantDetail',
      builder:
          (context, state) =>
              PlantDetailScreen(plantId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/stats',
      name: 'stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationSettingScreen(),
    ),
  ],
);
