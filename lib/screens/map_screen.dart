import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import 'minigames/reading_game_screen.dart';
import 'minigames/writing_game_screen.dart';
import 'minigames/listening_game_screen.dart';
import 'minigames/speaking_game_screen.dart';
import 'escape_room/escape_room_screen.dart';
import 'escape_room/er_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  int _selectedWorldIndex = 0;
  late AnimationController _walkController;
  late Animation<double> _walkAnim;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _walkAnim = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  Widget _getGameScreen(String type) {
    switch (type) {
      case 'reading':
        return const ReadingGameScreen();
      case 'writing':
        return const WritingGameScreen();
      case 'listening':
        return const ListeningGameScreen();
      case 'speaking':
        return const SpeakingGameScreen();
      case 'escape_room':
        return const EscapeRoomScreen();
      default:
        return const ReadingGameScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final worlds = MockData.worlds;
    final currentWorld = worlds[_selectedWorldIndex];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // World selector header
          _buildWorldSelector(worlds),

          // Map content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentWorld.darkColor,
                    AppColors.darkBg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // World header banner
                  _buildWorldBanner(currentWorld),

                  // Level map
                  Expanded(
                    child: _buildLevelMap(currentWorld),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSelector(List<WorldModel> worlds) {
    return Container(
      color: AppColors.darkCard,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗺️ Adventure Map',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: worlds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final w = worlds[i];
                final selected = i == _selectedWorldIndex;
                return GestureDetector(
                  onTap: w.unlocked
                      ? () => setState(() => _selectedWorldIndex = i)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [w.color, w.darkColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: selected ? null : AppColors.darkBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? w.color
                            : Colors.white.withValues(alpha: 0.1),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: w.color.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(
                          w.unlocked ? w.emoji : '🔒',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'World ${i + 1}',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                w.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: w.completionPercent,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    selected
                                        ? Colors.white
                                        : w.color.withValues(alpha: 0.6),
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldBanner(WorldModel world) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: world.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: world.color.withValues(alpha: 0.4)),
            ),
            child: Text(world.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  world.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: world.completionPercent,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(world.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(world.completionPercent * 100).toInt()}%',
                      style: TextStyle(
                        color: world.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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

  Widget _buildLevelMap(WorldModel world) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      itemCount: world.levels.length,
      itemBuilder: (context, i) {
        final level = world.levels[i];
        final isLeft = i % 2 == 0;
        return _buildLevelNode(level, isLeft, world.color, i == world.levels.length - 1);
      },
    );
  }

  Widget _buildLevelNode(
      LevelNode level, bool isLeft, Color worldColor, bool isLast) {
    final typeEmoji = {
      'reading': '📖',
      'writing': '✍️',
      'listening': '🎧',
      'speaking': '🎤',
      'mixed': '⚡',
      'escape_room': '🚪',
    };
    final typeColor = {
      'reading': AppColors.readingColor,
      'writing': AppColors.writingColor,
      'listening': AppColors.listeningColor,
      'speaking': AppColors.speakingColor,
      'mixed': AppColors.accentYellow,
      'escape_room': ERColors.accent,
    };

    return Column(
      children: [
        // Dashed connector line
        if (level.number > 1)
          Container(
            width: 3,
            height: 30,
            margin: EdgeInsets.only(
              left: isLeft ? 60 : 0,
              right: isLeft ? 0 : 60,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: level.unlocked
                    ? [worldColor, worldColor.withValues(alpha: 0.3)]
                    : [Colors.white.withValues(alpha: 0.15), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

        // Level node
        Row(
          mainAxisAlignment:
              isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: level.unlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _getGameScreen(level.type),
                        ),
                      );
                    }
                  : null,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Node circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: level.completed
                              ? LinearGradient(
                                  colors: [worldColor, worldColor.withValues(alpha: 0.6)],
                                )
                              : level.unlocked
                                  ? LinearGradient(
                                      colors: [
                                        worldColor.withValues(alpha: 0.4),
                                        worldColor.withValues(alpha: 0.2),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF374151),
                                        Color(0xFF1F2937),
                                      ],
                                    ),
                          boxShadow: level.unlocked
                              ? [
                                  BoxShadow(
                                    color: worldColor.withValues(
                                        alpha: level.completed ? 0.5 : 0.2),
                                    blurRadius: level.completed ? 20 : 8,
                                    spreadRadius: level.completed ? 3 : 0,
                                  ),
                                ]
                              : [],
                          border: Border.all(
                            color: level.completed
                                ? worldColor
                                : level.unlocked
                                    ? worldColor.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.1),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: level.unlocked
                              ? Text(
                                  typeEmoji[level.type] ?? '❓',
                                  style: const TextStyle(fontSize: 28),
                                )
                              : const Icon(Icons.lock_rounded,
                                  color: Colors.white30, size: 28),
                        ),
                      ),

                      // Checkpoint flag
                      if (level.isCheckpoint)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentYellow.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text('🚩',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),

                      // Treasure chest
                      if (level.hasTreasure && level.unlocked)
                        Positioned(
                          bottom: -8,
                          left: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentOrange.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text('💰',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Stars
                  StarRating(stars: level.stars, size: 14),

                  const SizedBox(height: 4),

                  // Label
                  SizedBox(
                    width: 85,
                    child: Text(
                      level.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: level.unlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  // Type tag
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (typeColor[level.type] ?? worldColor)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      level.type.toUpperCase(),
                      style: TextStyle(
                        color: typeColor[level.type] ?? worldColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
