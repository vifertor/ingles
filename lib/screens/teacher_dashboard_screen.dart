import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import 'teacher_students_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = MockData.students;
    final avgCompletion = students.map((s) => s.completionPercent).reduce((a, b) => a + b) / students.length;
    final activeStudents = students.where((s) => s.status == 'active').length;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.darkBg,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(background: _buildTeacherHeader()),
            title: const Text('Teacher Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            actions: [
              IconButton(onPressed: () {}, icon: Stack(children: [
                const Icon(Icons.notifications_rounded, color: Colors.white, size: 26),
                Positioned(right: 0, top: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.accentPink, shape: BoxShape.circle, border: Border.all(color: AppColors.darkBg, width: 1.5)))),
              ])),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats cards
                Row(
                  children: [
                    Expanded(child: _buildStatCard('👥', '${students.length}', 'Students', AppColors.primaryBlue)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('✅', '$activeStudents', 'Active', AppColors.accentGreen)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('📊', '${(avgCompletion * 100).toInt()}%', 'Avg Done', AppColors.primaryPurple)),
                  ],
                ),
                const SizedBox(height: 20),

                // Alert card
                _buildAlertCard(),
                const SizedBox(height: 20),

                // Class progress overview
                const SectionHeader(title: '📊 Class Overview'),
                const SizedBox(height: 14),
                _buildClassOverview(students),
                const SizedBox(height: 20),

                // Students quick list
                SectionHeader(title: '👥 Students', actionLabel: 'View All', onAction: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherStudentsScreen()));
                }),
                const SizedBox(height: 14),
                ...students.take(3).map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStudentQuickCard(s, context),
                )),
                const SizedBox(height: 20),

                // Recent activity
                const SectionHeader(title: '🕐 Recent Activity'),
                const SizedBox(height: 14),
                ..._buildActivityFeed(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF065F46), Color(0xFF1A1A2E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentGreen.withValues(alpha: 0.1)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('👨‍🏫', style: TextStyle(fontSize: 52)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning,', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
                        const Text('Mr. Salinas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4))),
                          child: const Text('Teacher Dashboard', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w700, fontSize: 11)),
                        ),
                      ],
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
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.warning_rounded, color: AppColors.accentOrange, size: 22)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ Attention Needed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                Text('Miguel Torres has been inactive for 5 days. Consider reaching out.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassOverview(List<StudentModel> students) {
    final skills = [
      {'label': 'Reading', 'color': AppColors.readingColor, 'avg': students.map((s) => s.skills.reading).reduce((a, b) => a + b) / students.length},
      {'label': 'Writing', 'color': AppColors.writingColor, 'avg': students.map((s) => s.skills.writing).reduce((a, b) => a + b) / students.length},
      {'label': 'Listening', 'color': AppColors.listeningColor, 'avg': students.map((s) => s.skills.listening).reduce((a, b) => a + b) / students.length},
      {'label': 'Speaking', 'color': AppColors.speakingColor, 'avg': students.map((s) => s.skills.speaking).reduce((a, b) => a + b) / students.length},
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: Column(
        children: skills.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 72, child: Text(s['label'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 12))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s['avg'] as double, minHeight: 10,
                    backgroundColor: (s['color'] as Color).withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(s['color'] as Color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${((s['avg'] as double) * 100).toInt()}%', style: TextStyle(color: s['color'] as Color, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStudentQuickCard(StudentModel student, BuildContext context) {
    final statusColor = student.status == 'active' ? AppColors.accentGreen : AppColors.accentOrange;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherStudentsScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
        child: Row(
          children: [
            Text(student.avatarEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('Level ${student.level} · ${(student.completionPercent * 100).toInt()}% complete', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor, boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 6)]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityFeed() {
    final activities = [
      {'emoji': '✅', 'text': 'Alex Rivera completed World 2 Level 3', 'time': '10 min ago', 'color': AppColors.accentGreen},
      {'emoji': '🎯', 'text': 'Holson Espinoza started Speaking Mission', 'time': '1h ago', 'color': AppColors.primaryBlue},
      {'emoji': '⚠️', 'text': 'Danny Aburto missed daily goal', 'time': '3h ago', 'color': AppColors.accentOrange},
      {'emoji': '🏆', 'text': 'Diego Ramírez earned Word Wizard badge', 'time': '5h ago', 'color': AppColors.accentYellow},
    ];
    return activities.map((a) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.3))),
            child: Center(child: Text(a['emoji'] as String, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['text'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(a['time'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    )).toList();
  }
}
