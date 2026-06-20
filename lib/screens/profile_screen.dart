import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final skills = [
      {'label': 'Reading', 'color': AppColors.readingColor, 'value': user.skills.reading, 'emoji': '📖'},
      {'label': 'Writing', 'color': AppColors.writingColor, 'value': user.skills.writing, 'emoji': '✍️'},
      {'label': 'Listening', 'color': AppColors.listeningColor, 'value': user.skills.listening, 'emoji': '🎧'},
      {'label': 'Speaking', 'color': AppColors.speakingColor, 'value': user.skills.speaking, 'emoji': '🎤'},
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.darkBg,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(context),
            ),
            title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // XP Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                  child: XpBar(xp: user.xp, maxXp: user.maxXp, level: user.level, color: AppColors.accentYellow),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(child: _buildStatCard('🔥', '${user.streak}', 'Day Streak', AppColors.accentOrange)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('🪙', '${user.coins}', 'Coins', AppColors.accentYellow)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('💎', '${user.gems}', 'Gems', AppColors.primaryCyan)),
                  ],
                ),
                const SizedBox(height: 20),

                // Skills breakdown
                const SectionHeader(title: '📊 Skills Progress'),
                const SizedBox(height: 14),
                ...skills.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSkillBar(s['label'] as String, s['emoji'] as String, s['color'] as Color, s['value'] as double),
                )),
                const SizedBox(height: 20),

                // Weekly chart
                const SectionHeader(title: '📈 Weekly Activity'),
                const SizedBox(height: 14),
                _buildWeeklyChart(),
                const SizedBox(height: 20),

                // Achievements summary
                const SectionHeader(title: '🏅 Achievements', actionLabel: 'See All'),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: MockData.achievements.map((a) => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: a.unlocked ? a.color.withValues(alpha: 0.15) : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: a.unlocked ? a.color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Icon(a.icon, color: a.unlocked ? a.color : Colors.white.withValues(alpha: 0.2), size: 24),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // History
                const SectionHeader(title: '📋 Recent Activity'),
                const SizedBox(height: 14),
                ..._buildRecentActivity(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1A0533), Color(0xFF2D1B69), Color(0xFF1A1A2E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryPurple.withValues(alpha: 0.1)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    AnimatedAvatar(emoji: user.avatarEmoji, size: 80),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                          Text('@${user.username}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                                child: Text('Lv. ${user.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              const Text('⭐', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text('${MockData.achievements.where((a) => a.unlocked).length}/${MockData.achievements.length} Badges',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSkillBar(String label, String emoji, Color color, double value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value, minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    const days = MockData.weeklyData;
    final maxXp = days.map((d) => d.xp).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((d) {
          final barH = (d.xp / maxXp) * 80;
          return Column(
            children: [
              Container(width: 30, height: barH, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 6),
              Text(d.day, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildRecentActivity() {
    final activities = [
      {'emoji': '📖', 'action': 'Completed Reading Level 4', 'time': '2h ago', 'xp': '+20'},
      {'emoji': '🎧', 'action': 'Listening Score: 90%', 'time': '5h ago', 'xp': '+15'},
      {'emoji': '✍️', 'action': 'Writing Mission Complete', 'time': '1d ago', 'xp': '+60'},
      {'emoji': '🏆', 'action': 'Earned "Word Wizard" badge', 'time': '2d ago', 'xp': '+200'},
    ];
    return activities.map((a) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: Row(
        children: [
          Text(a['emoji']!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['action']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                Text(a['time']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(a['xp']!, style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    )).toList();
  }
}
