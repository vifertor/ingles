import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── User Model ──────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarEmoji;
  final int level;
  final int xp;
  final int maxXp;
  final int coins;
  final int streak;
  final int gems;
  final bool isTeacher;
  final SkillProgress skills;
  final List<Achievement> achievements;
  final List<WeeklyProgress> weeklyProgress;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarEmoji,
    required this.level,
    required this.xp,
    required this.maxXp,
    required this.coins,
    required this.streak,
    required this.gems,
    required this.isTeacher,
    required this.skills,
    required this.achievements,
    required this.weeklyProgress,
  });
}

class SkillProgress {
  final double reading;
  final double writing;
  final double listening;
  final double speaking;

  const SkillProgress({
    required this.reading,
    required this.writing,
    required this.listening,
    required this.speaking,
  });
}

class WeeklyProgress {
  final String day;
  final int xp;

  const WeeklyProgress({required this.day, required this.xp});
}

// ─── Achievement Model ────────────────────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.xpReward,
  });
}

// ─── World/Level Model ────────────────────────────────────────────────────────
class WorldModel {
  final String id;
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color darkColor;
  final List<LevelNode> levels;
  final bool unlocked;
  final double completionPercent;

  const WorldModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.darkColor,
    required this.levels,
    required this.unlocked,
    required this.completionPercent,
  });
}

class LevelNode {
  final String id;
  final int number;
  final String title;
  final String type;
  final bool completed;
  final bool unlocked;
  final int stars;
  final bool isCheckpoint;
  final bool hasTreasure;

  const LevelNode({
    required this.id,
    required this.number,
    required this.title,
    required this.type,
    required this.completed,
    required this.unlocked,
    required this.stars,
    this.isCheckpoint = false,
    this.hasTreasure = false,
  });
}

// ─── Mission Model ────────────────────────────────────────────────────────────
class Mission {
  final String id;
  final String title;
  final String description;
  final String skill;
  final IconData icon;
  final Color color;
  final int progress;
  final int total;
  final int xpReward;
  final bool completed;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.skill,
    required this.icon,
    required this.color,
    required this.progress,
    required this.total,
    required this.xpReward,
    required this.completed,
  });
}

// ─── Ranking Model ────────────────────────────────────────────────────────────
class RankingEntry {
  final int rank;
  final String name;
  final String avatarEmoji;
  final int level;
  final int xp;
  final String badge;
  final bool isCurrentUser;

  const RankingEntry({
    required this.rank,
    required this.name,
    required this.avatarEmoji,
    required this.level,
    required this.xp,
    required this.badge,
    required this.isCurrentUser,
  });
}

// ─── Student Model (for teacher) ─────────────────────────────────────────────
class StudentModel {
  final String id;
  final String name;
  final String avatarEmoji;
  final int level;
  final double completionPercent;
  final SkillProgress skills;
  final int lastActive;
  final String status;
  final int missionsCompleted;
  final int totalTimeMinutes;

  const StudentModel({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.level,
    required this.completionPercent,
    required this.skills,
    required this.lastActive,
    required this.status,
    required this.missionsCompleted,
    required this.totalTimeMinutes,
  });
}

// ─── Mock Data ────────────────────────────────────────────────────────────────
class MockData {
  static const UserModel currentUser = UserModel(
    id: 'u1',
    name: 'Alex Rivera',
    username: 'alex_rv',
    email: 'alex@gamelish.com',
    avatarEmoji: '🦊',
    level: 12,
    xp: 3450,
    maxXp: 5000,
    coins: 1280,
    streak: 7,
    gems: 45,
    isTeacher: false,
    skills: const SkillProgress(
      reading: 0.75,
      writing: 0.60,
      listening: 0.85,
      speaking: 0.50,
    ),
    achievements: achievements,
    weeklyProgress: weeklyData,
  );

  static const UserModel teacherUser = UserModel(
    id: 't1',
    name: 'Mr. Salinas',
    username: 'mr_salinas',
    email: 'salinas@school.edu',
    avatarEmoji: '👨‍🏫',
    level: 25,
    xp: 12000,
    maxXp: 15000,
    coins: 5000,
    streak: 30,
    gems: 200,
    isTeacher: true,
    skills: const SkillProgress(
      reading: 0.95,
      writing: 0.90,
      listening: 0.95,
      speaking: 0.88,
    ),
    achievements: achievements,
    weeklyProgress: weeklyData,
  );

  static const List<WeeklyProgress> weeklyData = [
    WeeklyProgress(day: 'Mon', xp: 120),
    WeeklyProgress(day: 'Tue', xp: 80),
    WeeklyProgress(day: 'Wed', xp: 200),
    WeeklyProgress(day: 'Thu', xp: 150),
    WeeklyProgress(day: 'Fri', xp: 300),
    WeeklyProgress(day: 'Sat', xp: 250),
    WeeklyProgress(day: 'Sun', xp: 180),
  ];

  static const List<Achievement> achievements = [
    Achievement(
      id: 'a1',
      title: 'First Steps',
      description: 'Complete your first lesson',
      icon: Icons.star,
      color: AppColors.accentYellow,
      unlocked: true,
      xpReward: 50,
    ),
    Achievement(
      id: 'a2',
      title: 'Streak Master',
      description: 'Maintain a 7-day streak',
      icon: Icons.local_fire_department,
      color: AppColors.accentOrange,
      unlocked: true,
      xpReward: 100,
    ),
    Achievement(
      id: 'a3',
      title: 'Word Wizard',
      description: 'Learn 100 new words',
      icon: Icons.auto_stories,
      color: AppColors.primaryBlue,
      unlocked: true,
      xpReward: 200,
    ),
    Achievement(
      id: 'g4',
      title: 'Perfect Score',
      description: 'Get 100% in any quiz',
      icon: Icons.emoji_events,
      color: AppColors.accentGreen,
      unlocked: false,
      xpReward: 150,
    ),
    Achievement(
      id: 'd2',
      title: 'Speed Reader',
      description: 'Complete a reading in under 1 minute',
      icon: Icons.speed,
      color: AppColors.primaryCyan,
      unlocked: false,
      xpReward: 120,
    ),
    Achievement(
      id: 'h1',
      title: 'Pronunciation Pro',
      description: 'Score 90%+ on speaking',
      icon: Icons.mic,
      color: AppColors.speakingColor,
      unlocked: false,
      xpReward: 180,
    ),
  ];

  static final List<WorldModel> worlds = [
    const WorldModel(
      id: 'w1',
      name: 'Word Forest',
      subtitle: 'Master everyday vocabulary',
      emoji: '🌲',
      color: AppColors.accentGreen,
      darkColor: Color(0xFF065F46),
      unlocked: true,
      completionPercent: 0.85,
      levels: [
        LevelNode(
            id: 'l1',
            number: 1,
            title: 'Hello World',
            type: 'reading',
            completed: true,
            unlocked: true,
            stars: 3),
        LevelNode(
            id: 'l2',
            number: 2,
            title: 'ABC Song',
            type: 'listening',
            completed: true,
            unlocked: true,
            stars: 2),
        LevelNode(
            id: 'l3',
            number: 3,
            title: 'First Words',
            type: 'writing',
            completed: true,
            unlocked: true,
            stars: 3,
            isCheckpoint: true),
        LevelNode(
            id: 'l4',
            number: 4,
            title: 'Colors',
            type: 'reading',
            completed: true,
            unlocked: true,
            stars: 1),
        LevelNode(
            id: 'l5',
            number: 5,
            title: 'Animals',
            type: 'speaking',
            completed: false,
            unlocked: true,
            stars: 0,
            hasTreasure: true),
        LevelNode(
            id: 'l6',
            number: 6,
            title: 'The Lost Passport',
            type: 'escape_room',
            completed: false,
            unlocked: true,
            stars: 0),
      ],
    ),
    const WorldModel(
      id: 'w2',
      name: 'English City',
      subtitle: 'Real-life conversations',
      emoji: '🏙️',
      color: AppColors.primaryBlue,
      darkColor: Color(0xFF1E3A5F),
      unlocked: true,
      completionPercent: 0.40,
      levels: [
        LevelNode(
            id: 'l7',
            number: 1,
            title: 'At the Market',
            type: 'listening',
            completed: true,
            unlocked: true,
            stars: 3),
        LevelNode(
            id: 'l8',
            number: 2,
            title: 'Directions',
            type: 'speaking',
            completed: true,
            unlocked: true,
            stars: 2),
        LevelNode(
            id: 'l9',
            number: 3,
            title: 'Shopping',
            type: 'reading',
            completed: false,
            unlocked: true,
            stars: 0,
            isCheckpoint: true),
        LevelNode(
            id: 'l10',
            number: 4,
            title: 'Restaurant',
            type: 'writing',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l11',
            number: 5,
            title: 'Subway',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0,
            hasTreasure: true),
        LevelNode(
            id: 'l12',
            number: 6,
            title: 'City Boss',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0),
      ],
    ),
    const WorldModel(
      id: 'w3',
      name: 'Pronunciation Mountain',
      subtitle: 'Perfect your accent',
      emoji: '⛰️',
      color: AppColors.primaryPurple,
      darkColor: Color(0xFF3B0764),
      unlocked: false,
      completionPercent: 0.0,
      levels: [
        LevelNode(
            id: 'l13',
            number: 1,
            title: 'Vowels',
            type: 'speaking',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l14',
            number: 2,
            title: 'Consonants',
            type: 'speaking',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l15',
            number: 3,
            title: 'Stress',
            type: 'listening',
            completed: false,
            unlocked: false,
            stars: 0,
            isCheckpoint: true),
        LevelNode(
            id: 'l16',
            number: 4,
            title: 'Intonation',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l17',
            number: 5,
            title: 'Advanced Sounds',
            type: 'speaking',
            completed: false,
            unlocked: false,
            stars: 0,
            hasTreasure: true),
        LevelNode(
            id: 'l18',
            number: 6,
            title: 'Mountain Boss',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0),
      ],
    ),
    const WorldModel(
      id: 'w4',
      name: 'Advanced Castle',
      subtitle: 'Advanced English mastery',
      emoji: '🏰',
      color: AppColors.accentOrange,
      darkColor: Color(0xFF7C2D12),
      unlocked: false,
      completionPercent: 0.0,
      levels: [
        LevelNode(
            id: 'l19',
            number: 1,
            title: 'Academic Writing',
            type: 'writing',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l20',
            number: 2,
            title: 'Debate',
            type: 'speaking',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l21',
            number: 3,
            title: 'Literature',
            type: 'reading',
            completed: false,
            unlocked: false,
            stars: 0,
            isCheckpoint: true),
        LevelNode(
            id: 'l22',
            number: 4,
            title: 'Idioms',
            type: 'listening',
            completed: false,
            unlocked: false,
            stars: 0),
        LevelNode(
            id: 'l23',
            number: 5,
            title: 'Final Test',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0,
            hasTreasure: true),
        LevelNode(
            id: 'l24',
            number: 6,
            title: 'Grand Finale',
            type: 'mixed',
            completed: false,
            unlocked: false,
            stars: 0),
      ],
    ),
  ];

  static const List<Mission> dailyMissions = [
    Mission(
      id: 'm1',
      title: 'Read & Conquer',
      description: 'Complete 3 reading exercises',
      skill: 'Reading',
      icon: Icons.menu_book,
      color: AppColors.readingColor,
      progress: 2,
      total: 3,
      xpReward: 80,
      completed: false,
    ),
    Mission(
      id: 'm2',
      title: 'Spell Master',
      description: 'Write 5 words correctly',
      skill: 'Writing',
      icon: Icons.edit_note,
      color: AppColors.writingColor,
      progress: 5,
      total: 5,
      xpReward: 60,
      completed: true,
    ),
    Mission(
      id: 'm3',
      title: 'Ear Training',
      description: 'Listen to 2 audio clips',
      skill: 'Listening',
      icon: Icons.headphones,
      color: AppColors.listeningColor,
      progress: 0,
      total: 2,
      xpReward: 70,
      completed: false,
    ),
  ];

  static const List<RankingEntry> rankings = [
    RankingEntry(
        rank: 1,
        name: 'Holson E',
        avatarEmoji: '🌟',
        level: 18,
        xp: 8920,
        badge: '🥇',
        isCurrentUser: false),
    RankingEntry(
        rank: 2,
        name: 'Danny A.',
        avatarEmoji: '🐯',
        level: 16,
        xp: 7650,
        badge: '🥈',
        isCurrentUser: false),
    RankingEntry(
        rank: 3,
        name: 'Zoe K.',
        avatarEmoji: '🦋',
        level: 15,
        xp: 6890,
        badge: '🥉',
        isCurrentUser: false),
    RankingEntry(
        rank: 4,
        name: 'Alex Rivera',
        avatarEmoji: '🦊',
        level: 12,
        xp: 3450,
        badge: '⭐',
        isCurrentUser: true),
    RankingEntry(
        rank: 5,
        name: 'Sam T.',
        avatarEmoji: '🐸',
        level: 11,
        xp: 3100,
        badge: '⭐',
        isCurrentUser: false),
    RankingEntry(
        rank: 6,
        name: 'Osman Salinas.',
        avatarEmoji: '🦄',
        level: 10,
        xp: 2800,
        badge: '⭐',
        isCurrentUser: false),
    RankingEntry(
        rank: 7,
        name: 'Leo M.',
        avatarEmoji: '🦁',
        level: 9,
        xp: 2400,
        badge: '⭐',
        isCurrentUser: false),
    RankingEntry(
        rank: 8,
        name: 'Aria B.',
        avatarEmoji: '🐼',
        level: 8,
        xp: 1900,
        badge: '⭐',
        isCurrentUser: false),
  ];

  static final List<StudentModel> students = [
    const StudentModel(
      id: 's1',
      name: 'Danny Aburto',
      avatarEmoji: '🐯',
      level: 8,
      completionPercent: 0.72,
      skills: SkillProgress(
          reading: 0.85, writing: 0.60, listening: 0.78, speaking: 0.45),
      lastActive: 1,
      status: 'active',
      missionsCompleted: 14,
      totalTimeMinutes: 340,
    ),
    const StudentModel(
      id: 's2',
      name: 'Sofia López',
      avatarEmoji: '🦋',
      level: 10,
      completionPercent: 0.88,
      skills: SkillProgress(
          reading: 0.90, writing: 0.85, listening: 0.92, speaking: 0.80),
      lastActive: 0,
      status: 'active',
      missionsCompleted: 22,
      totalTimeMinutes: 520,
    ),
    const StudentModel(
      id: 's3',
      name: 'Miguel Torres',
      avatarEmoji: '🐸',
      level: 5,
      completionPercent: 0.35,
      skills: SkillProgress(
          reading: 0.40, writing: 0.30, listening: 0.50, speaking: 0.20),
      lastActive: 5,
      status: 'inactive',
      missionsCompleted: 6,
      totalTimeMinutes: 120,
    ),
    const StudentModel(
      id: 's4',
      name: 'Isabella Cruz',
      avatarEmoji: '🦄',
      level: 7,
      completionPercent: 0.60,
      skills: SkillProgress(
          reading: 0.65, writing: 0.55, listening: 0.70, speaking: 0.50),
      lastActive: 2,
      status: 'active',
      missionsCompleted: 12,
      totalTimeMinutes: 280,
    ),
    const StudentModel(
      id: 's5',
      name: 'Diego Ramírez',
      avatarEmoji: '🦁',
      level: 9,
      completionPercent: 0.78,
      skills: SkillProgress(
          reading: 0.80, writing: 0.75, listening: 0.82, speaking: 0.70),
      lastActive: 1,
      status: 'active',
      missionsCompleted: 18,
      totalTimeMinutes: 420,
    ),
  ];

  static final List<Map<String, dynamic>> avatarOptions = [
    {'emoji': '🦊', 'name': 'Fox'},
    {'emoji': '🐯', 'name': 'Tiger'},
    {'emoji': '🦋', 'name': 'Butterfly'},
    {'emoji': '🐸', 'name': 'Frog'},
    {'emoji': '🦄', 'name': 'Unicorn'},
    {'emoji': '🦁', 'name': 'Lion'},
    {'emoji': '🐼', 'name': 'Panda'},
    {'emoji': '🐨', 'name': 'Koala'},
    {'emoji': '🦖', 'name': 'Dino'},
    {'emoji': '🐉', 'name': 'Dragon'},
    {'emoji': '🦅', 'name': 'Eagle'},
    {'emoji': '🐬', 'name': 'Dolphin'},
  ];
}
