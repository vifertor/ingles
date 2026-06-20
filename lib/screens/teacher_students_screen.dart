import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});
  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  int? _selectedStudentIndex;
  String _filter = 'All';
  final List<String> _filters = ['All', 'Active', 'Inactive', 'Top'];

  List<StudentModel> get _filteredStudents {
    final s = MockData.students;
    switch (_filter) {
      case 'Active': return s.where((st) => st.status == 'active').toList();
      case 'Inactive': return s.where((st) => st.status == 'inactive').toList();
      case 'Top': return [...s]..sort((a, b) => b.completionPercent.compareTo(a.completionPercent));
      default: return s;
    }
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👥 My Students', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                        Text('Track individual progress', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24)),
                ],
              ),
            ),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: _filters.map((f) {
                  final selected = f == _filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected ? AppColors.primaryGradient : null,
                          color: selected ? null : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(f, style: TextStyle(color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _selectedStudentIndex != null
                  ? _buildStudentDetail(MockData.students[_selectedStudentIndex!])
                  : _buildStudentList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    final students = _filteredStudents;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = students[i];
        final origIndex = MockData.students.indexOf(s);
        final statusColor = s.status == 'active' ? AppColors.accentGreen : AppColors.accentOrange;
        return GestureDetector(
          onTap: () => setState(() => _selectedStudentIndex = origIndex),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
            child: Row(
              children: [
                Stack(
                  children: [
                    Text(s.avatarEmoji, style: const TextStyle(fontSize: 42)),
                    Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor, border: Border.all(color: AppColors.darkCard, width: 2)))),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('Level ${s.level} · ${s.missionsCompleted} missions done', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: s.completionPercent, minHeight: 7,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(s.completionPercent * 100).toInt()}%', style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w800, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                    const SizedBox(height: 4),
                    Text('${s.lastActive}d ago', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentDetail(StudentModel student) {
    final skills = [
      {'label': 'Reading', 'color': AppColors.readingColor, 'value': student.skills.reading, 'emoji': '📖'},
      {'label': 'Writing', 'color': AppColors.writingColor, 'value': student.skills.writing, 'emoji': '✍️'},
      {'label': 'Listening', 'color': AppColors.listeningColor, 'value': student.skills.listening, 'emoji': '🎧'},
      {'label': 'Speaking', 'color': AppColors.speakingColor, 'value': student.skills.speaking, 'emoji': '🎤'},
    ];
    final maxSkill = skills.reduce((a, b) => (a['value'] as double) > (b['value'] as double) ? a : b);
    final minSkill = skills.reduce((a, b) => (a['value'] as double) < (b['value'] as double) ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedStudentIndex = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Student card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryPurple.withValues(alpha: 0.2), AppColors.darkCard], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(student.avatarEmoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                      Text('Level ${student.level}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _miniStat('⏱️', '${student.totalTimeMinutes}m', 'Time'),
                          const SizedBox(width: 10),
                          _miniStat('✅', '${student.missionsCompleted}', 'Missions'),
                          const SizedBox(width: 10),
                          _miniStat('📅', '${student.lastActive}d', 'Last Active'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Completion
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Overall Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('${(student.completionPercent * 100).toInt()}%', style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: student.completionPercent, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.08), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Highlights
          Row(
            children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3))),
                child: Column(children: [
                  const Text('💪', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  const Text('Strength', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(maxSkill['label'] as String, style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w800, fontSize: 13)),
                ]),
              )),
              const SizedBox(width: 10),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3))),
                child: Column(children: [
                  const Text('🎯', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  const Text('Needs Work', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(minSkill['label'] as String, style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.w800, fontSize: 13)),
                ]),
              )),
            ],
          ),
          const SizedBox(height: 16),
          // Skills
          const Align(alignment: Alignment.centerLeft, child: Text('Skills Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
          const SizedBox(height: 12),
          ...skills.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: (s['color'] as Color).withValues(alpha: 0.2))),
              child: Row(
                children: [
                  Text(s['emoji'] as String, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(s['label'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${((s['value'] as double) * 100).toInt()}%', style: TextStyle(color: s['color'] as Color, fontWeight: FontWeight.w800, fontSize: 13)),
                        ]),
                        const SizedBox(height: 6),
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: s['value'] as double, minHeight: 8, backgroundColor: (s['color'] as Color).withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation<Color>(s['color'] as Color))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
