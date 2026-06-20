import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import 'minigames/reading_game_screen.dart';
import 'minigames/writing_game_screen.dart';
import 'minigames/listening_game_screen.dart';
import 'minigames/speaking_game_screen.dart';
import 'escape_room/escape_room_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  final user = MockData.currentUser;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: CustomScrollView(
        slivers: [
          // App Bar Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.darkBg,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_rounded,
                        color: Colors.white, size: 26),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.accentPink,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkBg, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            title: FadeTransition(
              opacity: _headerFade,
              child: const Text('Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                _buildStatsRow(),
                const SizedBox(height: 24),

                // Daily streak banner
                _buildStreakBanner(),
                const SizedBox(height: 24),

                // Escape Room special module
                _buildEscapeRoomBanner(),
                const SizedBox(height: 24),

                // Active missions
                const SectionHeader(title: '🎯 Daily Missions', actionLabel: 'See All'),
                const SizedBox(height: 12),
                ...MockData.dailyMissions.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMissionCard(m),
                    )),
                const SizedBox(height: 24),

                // Skills quick access
                const SectionHeader(title: '🎮 Practice Skills', actionLabel: 'All'),
                const SizedBox(height: 16),
                _buildSkillsGrid(),
                const SizedBox(height: 24),

                // Progress overview
                const SectionHeader(title: '📊 Your Progress'),
                const SizedBox(height: 16),
                _buildProgressCard(),
                const SizedBox(height: 24),

                // Achievements preview
                const SectionHeader(title: '🏆 Achievements', actionLabel: 'View All'),
                const SizedBox(height: 16),
                _buildAchievementsRow(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0533), Color(0xFF2D1B69), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCyan.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedAvatar(emoji: user.avatarEmoji, size: 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👋 Welcome back,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          XpBar(
                            xp: user.xp,
                            maxXp: user.maxXp,
                            level: user.level,
                            color: AppColors.accentYellow,
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

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatChip(
            icon: Icons.monetization_on_rounded,
            value: '${user.coins}',
            label: 'Coins',
            color: AppColors.accentYellow,
          ),
          const SizedBox(width: 10),
          StatChip(
            icon: Icons.local_fire_department_rounded,
            value: '${user.streak}',
            label: 'Streak',
            color: AppColors.accentOrange,
          ),
          const SizedBox(width: 10),
          StatChip(
            icon: Icons.diamond_rounded,
            value: '${user.gems}',
            label: 'Gems',
            color: AppColors.primaryCyan,
          ),
          const SizedBox(width: 10),
          StatChip(
            icon: Icons.stars_rounded,
            value: '${user.level}',
            label: 'Level',
            color: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.streak} Day Streak!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  "Don't break the chain! Keep learning today.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎁 +50 XP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscapeRoomBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EscapeRoomScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E6B), // darkBlue from Escape Room
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A017).withValues(alpha: 0.5), // accent gold
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFD4A017), width: 2),
        ),
        child: Row(
          children: [
            const Text('🚪', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESCAPE ROOM',
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'The Lost Passport',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Interactive English Challenge. Find your passport before the flight leaves!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final progress = mission.progress / mission.total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: mission.completed
              ? mission.color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: mission.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: mission.color.withValues(alpha: 0.3)),
            ),
            child: Icon(mission.icon, color: mission.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (mission.completed) ...[
                      const SizedBox(width: 6),
                      const Text('✅', style: TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
                Text(
                  mission.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              mission.completed
                                  ? AppColors.accentGreen
                                  : mission.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${mission.progress}/${mission.total}',
                      style: TextStyle(
                        color: mission.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.accentYellow.withValues(alpha: 0.3)),
            ),
            child: Text(
              '+${mission.xpReward}',
              style: const TextStyle(
                color: AppColors.accentYellow,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid() {
    final skills = [
      {
        'label': 'Reading',
        'icon': Icons.menu_book_rounded,
        'color': AppColors.readingColor,
        'progress': user.skills.reading,
        'emoji': '📖',
        'screen': const ReadingGameScreen(),
      },
      {
        'label': 'Writing',
        'icon': Icons.edit_note_rounded,
        'color': AppColors.writingColor,
        'progress': user.skills.writing,
        'emoji': '✍️',
        'screen': const WritingGameScreen(),
      },
      {
        'label': 'Listening',
        'icon': Icons.headphones_rounded,
        'color': AppColors.listeningColor,
        'progress': user.skills.listening,
        'emoji': '🎧',
        'screen': const ListeningGameScreen(),
      },
      {
        'label': 'Speaking',
        'icon': Icons.mic_rounded,
        'color': AppColors.speakingColor,
        'progress': user.skills.speaking,
        'emoji': '🎤',
        'screen': const SpeakingGameScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: skills.length,
      itemBuilder: (context, i) {
        final skill = skills[i];
        return SkillBadge(
          label: skill['label'] as String,
          icon: skill['icon'] as IconData,
          color: skill['color'] as Color,
          progress: skill['progress'] as double,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => skill['screen'] as Widget),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressCard() {
    const days = MockData.weeklyData;
    final maxXp = days.map((d) => d.xp).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly XP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This Week',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final barHeight = (d.xp / maxXp) * 80;
              final isToday = d.day == 'Fri';
              return Column(
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${d.xp}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppColors.primaryPurple.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.day,
                    style: TextStyle(
                      color: isToday
                          ? AppColors.primaryPurple
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight:
                          isToday ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsRow() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MockData.achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = MockData.achievements[i];
          return Container(
            width: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: a.unlocked
                  ? a.color.withValues(alpha: 0.15)
                  : AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: a.unlocked
                    ? a.color.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  a.icon,
                  color: a.unlocked ? a.color : Colors.white.withValues(alpha: 0.2),
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  a.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: a.unlocked
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
