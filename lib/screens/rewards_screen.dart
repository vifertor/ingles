import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = MockData.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🏆 Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.accentYellow.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.4))),
                            child: Row(children: [const Text('🪙', style: TextStyle(fontSize: 16)), const SizedBox(width: 4), Text('${user.coins}', style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w900, fontSize: 14))]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primaryCyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.4))),
                            child: Row(children: [const Text('💎', style: TextStyle(fontSize: 16)), const SizedBox(width: 4), Text('${user.gems}', style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.w900, fontSize: 14))]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white38,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Achievements'),
                        Tab(text: 'Chests'),
                        Tab(text: 'Shop'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAchievementsTab(),
                  _buildChestsTab(),
                  _buildShopTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    const achievements = MockData.achievements;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: achievements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final a = achievements[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: a.unlocked ? a.color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
            boxShadow: a.unlocked ? [BoxShadow(color: a.color.withValues(alpha: 0.15), blurRadius: 12)] : [],
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: a.unlocked ? a.color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.unlocked ? a.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08)),
                ),
                child: Icon(a.icon, color: a.unlocked ? a.color : Colors.white.withValues(alpha: 0.2), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(a.title, style: TextStyle(color: a.unlocked ? Colors.white : Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 14)),
                        if (a.unlocked) ...[const SizedBox(width: 6), const Text('✅', style: TextStyle(fontSize: 12))],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(a.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: a.unlocked ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('+${a.xpReward} XP',
                  style: TextStyle(color: a.unlocked ? AppColors.accentYellow : Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChestsTab() {
    final chests = [
      {'name': 'Bronze Chest', 'emoji': '📦', 'cost': 100, 'color': AppColors.accentOrange, 'unlocked': true, 'reward': '50-100 XP'},
      {'name': 'Silver Chest', 'emoji': '🎁', 'cost': 250, 'color': const Color(0xFFC0C0C0), 'unlocked': true, 'reward': '100-200 XP'},
      {'name': 'Gold Chest', 'emoji': '💰', 'cost': 500, 'color': AppColors.accentYellow, 'unlocked': true, 'reward': '200-400 XP'},
      {'name': 'Diamond Chest', 'emoji': '💎', 'cost': 1000, 'color': AppColors.primaryCyan, 'unlocked': false, 'reward': '500-1000 XP'},
      {'name': 'Legendary Chest', 'emoji': '🔮', 'cost': 2500, 'color': AppColors.primaryPurple, 'unlocked': false, 'reward': 'Exclusive items'},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.9),
      itemCount: chests.length,
      itemBuilder: (context, i) {
        final c = chests[i];
        final color = c['color'] as Color;
        final unlocked = c['unlocked'] as bool;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: unlocked ? 0.4 : 0.15)),
            boxShadow: unlocked ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(c['emoji'] as String, style: TextStyle(fontSize: 48, color: unlocked ? null : null)),
              const SizedBox(height: 8),
              Text(c['name'] as String, textAlign: TextAlign.center, style: TextStyle(color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4),
              Text(c['reward'] as String, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: unlocked ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)]) : null,
                  color: unlocked ? null : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('${c['cost']}', style: TextStyle(color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopTab() {
    final items = [
      {'name': 'XP Booster', 'emoji': '⚡', 'desc': '2x XP for 30 min', 'cost': 200, 'color': AppColors.accentYellow},
      {'name': 'Shield', 'emoji': '🛡️', 'desc': 'Protect your streak', 'cost': 150, 'color': AppColors.primaryBlue},
      {'name': 'Hint Pack', 'emoji': '💡', 'desc': '5 extra hints', 'cost': 100, 'color': AppColors.accentGreen},
      {'name': 'Crown Avatar', 'emoji': '👑', 'desc': 'Exclusive frame', 'cost': 500, 'color': AppColors.accentOrange},
      {'name': 'Dragon Badge', 'emoji': '🐉', 'desc': 'Rare achievement', 'cost': 800, 'color': AppColors.accentPink},
      {'name': 'Time Freeze', 'emoji': '⏱️', 'desc': 'Pause quiz timer', 'cost': 300, 'color': AppColors.primaryCyan},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.25))),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.4))),
                child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(item['desc'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text('${item['cost']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
