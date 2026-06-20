import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _periods = ['Weekly', 'Monthly', 'All Time'];

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
    const rankings = MockData.rankings;
    final top3 = rankings.take(3).toList();
    final rest = rankings.skip(3).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryPurple.withValues(alpha: 0.3), AppColors.darkBg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  const Text('🏆 Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
                  const SizedBox(height: 4),
                  Text('Compete with students worldwide', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
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
                      tabs: _periods.map((p) => Tab(text: p)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(3, (_) => _buildRankingList(top3, rest)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList(List<RankingEntry> top3, List<RankingEntry> rest) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Podium
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: _buildPodium(top3),
          ),
          // Rest of list
          ...rest.asMap().entries.map((e) => _buildRankRow(e.value)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPodium(List<RankingEntry> top3) {
    if (top3.length < 3) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        Expanded(child: _buildPodiumItem(top3[1], 2, 100, AppColors.primaryBlue)),
        const SizedBox(width: 8),
        // 1st place
        Expanded(child: _buildPodiumItem(top3[0], 1, 140, AppColors.accentYellow)),
        const SizedBox(width: 8),
        // 3rd place
        Expanded(child: _buildPodiumItem(top3[2], 3, 80, AppColors.accentOrange)),
      ],
    );
  }

  Widget _buildPodiumItem(RankingEntry entry, int rank, double podiumHeight, Color color) {
    final medals = ['🥇', '🥈', '🥉'];
    return Column(
      children: [
        Text(entry.avatarEmoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        Text(entry.name.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(medals[rank - 1], style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Container(
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.5)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                Text('Lv.${entry.level}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(RankingEntry entry) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.primaryPurple.withValues(alpha: 0.2) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: entry.isCurrentUser ? AppColors.primaryPurple.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06)),
        boxShadow: entry.isCurrentUser ? [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.2), blurRadius: 12)] : [],
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#${entry.rank}', style: TextStyle(color: entry.isCurrentUser ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 14))),
          const SizedBox(width: 10),
          Text(entry.avatarEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name, style: TextStyle(color: entry.isCurrentUser ? Colors.white : Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w800, fontSize: 14)),
                    if (entry.isCurrentUser) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primaryPurple, borderRadius: BorderRadius.circular(8)), child: const Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)))],
                  ],
                ),
                Text('Level ${entry.level} · ${entry.xp} XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(entry.badge, style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
