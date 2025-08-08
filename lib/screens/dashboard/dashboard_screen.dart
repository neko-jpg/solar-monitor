import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../providers/plants_provider.dart';
import '../../providers/notification_settings_provider.dart';

import 'widgets/plant_carousel_card.dart';
import 'widgets/plant_stat_card.dart';
import 'widgets/plant_grid_card.dart';
import 'widgets/plant_list_item.dart';

enum DashboardView { featured, grid, list }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final controller = PageController(viewportFraction: 0.92);
  int current = 0;
  DashboardView view = DashboardView.featured;

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);

    // ===== AppBar（右上メニューで表示切替） =====
    final appBar = AppBar(
      backgroundColor:
          view == DashboardView.featured
              ? AppTok.darkBg
              : const Color(0xFFF6F7FB),
      elevation: 0,
      title: Text(
        view == DashboardView.featured
            ? 'Solar Power Monitoring'
            : 'Solar Power',
        style: TextStyle(
          color: view == DashboardView.featured ? Colors.white : Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        PopupMenuButton<DashboardView>(
          initialValue: view,
          onSelected: (v) => setState(() => view = v),
          itemBuilder:
              (_) => const [
                PopupMenuItem(
                  value: DashboardView.featured,
                  child: Text('Featured'),
                ),
                PopupMenuItem(value: DashboardView.grid, child: Text('Grid')),
                PopupMenuItem(value: DashboardView.list, child: Text('List')),
              ],
        ),
      ],
    );

    // ===== Body（分岐） =====
    Widget body;
    if (plants.isEmpty) {
      body = Center(
        child: Text(
          'No plants yet',
          style: TextStyle(
            color:
                view == DashboardView.featured ? Colors.white : Colors.black54,
          ),
        ),
      );
    } else if (view == DashboardView.featured) {
      // ダーク基調：上段特大カード＋下段ミニカード
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 230,
            child: PageView.builder(
              controller: controller,
              onPageChanged: (i) => setState(() => current = i),
              itemCount: plants.length,
              itemBuilder:
                  (_, i) => PlantCarouselCard(
                    plant: plants[i],
                    onTap:
                        () => context.pushNamed(
                          'plantDetail',
                          pathParameters: {'id': plants[i].id},
                        ),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(plants.length, (i) {
                final active = i == current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 8 : 6,
                  height: active ? 8 : 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(active ? 0.9 : 0.4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final others =
                    plants.where((p) => p != plants[current]).toList();
                final p = others[i];
                return PlantStatCard(
                  plant: p,
                  onTap:
                      () => context.pushNamed(
                        'plantDetail',
                        pathParameters: {'id': p.id},
                      ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: (plants.length - 1).clamp(0, 999),
            ),
          ),
          const Spacer(),
        ],
      );
    } else if (view == DashboardView.grid) {
      // 白カードのグリッド
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                'Solar Power',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: plants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder:
                    (_, i) => PlantGridCard(
                      plant: plants[i],
                      onTap:
                          () => context.pushNamed(
                            'plantDetail',
                            pathParameters: {'id': plants[i].id},
                          ),
                    ),
              ),
            ),
          ],
        ),
      );
    } else {
      // List（Issues / Others）
      body = _IssuesListBody();
    }

    return Scaffold(
      backgroundColor:
          view == DashboardView.featured
              ? AppTok.darkBg
              : const Color(0xFFF6F7FB),
      appBar: appBar,
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('addPlant'),
        backgroundColor: AppTok.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===== Issuesリスト本体 =====
class _IssuesListBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final settings = ref.watch(notificationSettingsProvider);

    bool isIssue(plant) {
      final latest =
          plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
      final max =
          plant.readings.isEmpty
              ? 0.0
              : plant.readings
                  .map((e) => e.power)
                  .reduce((a, b) => a > b ? a : b);
      if (settings.abnormalAlert && settings.thresholdKw > 0) {
        return latest < settings.thresholdKw;
      }
      return max > 0 ? latest < max * 0.4 : false; // デフォ基準
    }

    final issues = plants.where(isIssue).toList();
    final others = plants.where((p) => !isIssue(p)).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Solar Power',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        const _SectionHeader('Plants with Issues'),
        if (issues.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No issues detected',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...issues.map(
            (p) => PlantListItem(
              plant: p,
              onTap:
                  () => GoRouter.of(
                    context,
                  ).pushNamed('plantDetail', pathParameters: {'id': p.id}),
            ),
          ),
        const _SectionHeader('Other Plants'),
        ...others.map(
          (p) => PlantListItem(
            plant: p,
            onTap:
                () => GoRouter.of(
                  context,
                ).pushNamed('plantDetail', pathParameters: {'id': p.id}),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
