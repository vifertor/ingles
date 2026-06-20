import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/escape_room_provider.dart';
import 'er_widgets.dart';

/// Final celebration screen shown after Room 4 is successfully completed.
class EscapeRoomFinish extends StatelessWidget {
  final VoidCallback onExit;
  const EscapeRoomFinish({super.key, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EscapeRoomProvider>();
    final codes = provider.getAllCodes();

    // Total stats across all rooms (r1–r3; r4 is the puzzle itself)
    int totalCorrect = 0;
    int totalQ = 0;
    for (final id in ['r1', 'r2', 'r3']) {
      final room = provider.progress.rooms[id];
      if (room != null) {
        totalCorrect += room.correctAnswers;
        totalQ += room.totalQuestions;
      }
    }
    final double pct = totalQ > 0 ? totalCorrect / totalQ : 0;

    return Scaffold(
      backgroundColor: ERColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Trophy ─────────────────────────────────────────────
              const Center(
                child: Text('🏆', style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 16),

              const Text(
                'MISSION COMPLETE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ERColors.cream,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You found your passport and made it to the gate just in time!\nHave a great flight! ✈️',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 32),

              // ── Mission report card ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withAlpha(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Text('📋', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('Mission Report',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Room results
                    _roomRow(
                      '📖', 'Room 1 — Vocabulary',
                      codes['r1'],
                      provider.progress.rooms['r1'],
                      takePosition: 0,
                      accentColor: ERColors.accent,
                    ),
                    const SizedBox(height: 10),
                    _roomRow(
                      '✍️', 'Room 2 — Grammar',
                      codes['r2'],
                      provider.progress.rooms['r2'],
                      takePosition: 1,
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 10),
                    _roomRow(
                      '🎧', 'Room 3 — Listening',
                      codes['r3'],
                      provider.progress.rooms['r3'],
                      takePosition: 2,
                      accentColor: ERColors.green,
                    ),
                    const SizedBox(height: 10),
                    _roomRow(
                      '🔮', 'Room 4 — Final Puzzle',
                      codes['r4'],
                      null,
                      takePosition: 3,
                      accentColor: const Color(0xFFE63946),
                      isVault: true,
                    ),

                    const Divider(color: Colors.white24, height: 28),

                    // Total accuracy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Accuracy:',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 15)),
                        Text(
                          '${(pct * 100).round()}%',
                          style: const TextStyle(
                              color: ERColors.green,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              ERNextButton(
                label: '🏠  Back to Dashboard',
                onTap: () {
                  provider.resetAll();
                  onExit();
                },
                color: ERColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomRow(
    String icon,
    String label,
    String? code,
    dynamic roomResult, {
    required int takePosition,
    required Color accentColor,
    bool isVault = false,
  }) {
    final chars = (code ?? '????').padRight(4, '?').split('');
    final takenChar = takePosition < chars.length ? chars[takePosition] : '?';
    final score = (roomResult != null && !isVault)
        ? '${roomResult.correctAnswers}/${roomResult.totalQuestions}'
        : isVault
            ? 'Solved ✓'
            : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                Text(score,
                    style: TextStyle(
                        color: accentColor.withAlpha(180), fontSize: 11)),
              ],
            ),
          ),
          // Code with highlighted char
          Row(
            children: List.generate(4, (i) {
              final isHighlighted = i == takePosition;
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 28,
                height: 32,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? accentColor.withAlpha(60)
                      : Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isHighlighted
                        ? accentColor
                        : Colors.white.withAlpha(25),
                    width: isHighlighted ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  chars[i],
                  style: TextStyle(
                    color:
                        isHighlighted ? accentColor : Colors.white38,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          // Contributed char pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              takenChar,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
