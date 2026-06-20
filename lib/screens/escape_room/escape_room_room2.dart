import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/escape_room_provider.dart';
import 'er_widgets.dart';
import 'room_summary_screen.dart';

/// ROOM 2 — Grammar: Fix broken sentences by choosing the right word
class EscapeRoomRoom2 extends StatefulWidget {
  final VoidCallback onComplete;
  const EscapeRoomRoom2({super.key, required this.onComplete});
  @override
  State<EscapeRoomRoom2> createState() => _EscapeRoomRoom2State();
}

class _EscapeRoomRoom2State extends State<EscapeRoomRoom2> {
  int _activeSentence = -1;
  bool _submitted = false;
  bool _showSummary = false;
  int _correct = 0;

  final List<Map<String, dynamic>> _sentences = [
    {
      'pre': 'I ',
      'post': ' my passport yesterday.',
      'answer': 'lost',
      'pool': ['lost', 'lose', 'find', 'forgot'],
      'hint': 'Past tense of "to lose"',
      'selected': null,
    },
    {
      'pre': 'We ',
      'post': ' at Gate 7 for two hours.',
      'answer': 'waited',
      'pool': ['waited', 'wait', 'went', 'looked'],
      'hint': 'Past tense of "to wait"',
      'selected': null,
    },
    {
      'pre': 'The flight ',
      'post': ' in exactly 20 minutes.',
      'answer': 'departs',
      'pool': ['departed', 'departs', 'fly', 'goes'],
      'hint': 'Present tense for a scheduled event',
      'selected': null,
    },
    {
      'pre': 'She ',
      'post': ' her boarding pass at the gate.',
      'answer': 'showed',
      'pool': ['showed', 'shows', 'seen', 'gave'],
      'hint': 'Past tense of "to show"',
      'selected': null,
    },
  ];

  final List<String?> _userAnswers = [null, null, null, null];

  void _selectWord(int sentIdx, String word) {
    if (_submitted) return;
    setState(() {
      _userAnswers[sentIdx] = word;
      _activeSentence = -1;
    });
  }

  void _submit() {
    int c = 0;
    for (int i = 0; i < _sentences.length; i++) {
      if (_userAnswers[i] == _sentences[i]['answer']) c++;
    }
    setState(() { _submitted = true; _correct = c; });
  }

  void _finish() {
    final provider = context.read<EscapeRoomProvider>();
    provider.completeRoom('r2', _correct, _sentences.length);
    setState(() => _showSummary = true);
  }

  bool get _allFilled => _userAnswers.every((a) => a != null);

  @override
  Widget build(BuildContext context) {
    if (_showSummary) {
      final provider = context.watch<EscapeRoomProvider>();
      final result = provider.progress.rooms['r2'];
      if (result == null) return const SizedBox.shrink();
      return RoomSummaryScreen(
        roomName: 'Room 2 — Grammar',
        correct: result.correctAnswers,
        total: result.totalQuestions,
        code: result.code,
        codeContributionIndex: 1, // Room 2 → 2nd character
        isPassed: result.isPassed,
        onRetry: () {
          provider.retryRoom('r2');
          setState(() {
            _activeSentence = -1;
            _submitted = false;
            _showSummary = false;
            _correct = 0;
            for(int i = 0; i < _userAnswers.length; i++) {
              _userAnswers[i] = null;
            }
          });
        },
        onNext: widget.onComplete,
      );
    }

    return ERScaffold(
      topColor: const Color(0xFF1A0D2E),
      botColor: const Color(0xFF0D1B2A),
      roomLabel: '✍️ Room 2 — Grammar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ERProgress(current: _submitted ? 4 : _userAnswers.where((a) => a != null).length, total: 4, color: const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),

          // Officer character
          DialogueScene(
            key: ValueKey('r2_$_submitted'),
            characterFace: '😤',
            characterBody: '👮',
            characterColor: const Color(0xFF778DA9),
            characterName: 'Officer Carlos',
            message: _submitted
                ? (_correct == 4
                    ? 'Amazing! All sentences are correct! You clearly know your tenses! 🎉'
                    : 'Good effort! You got $_correct out of 4. Keep working on those verb tenses!')
                : 'I found this torn note at the airport. Can you fix these broken sentences? Tap each blank to choose the right word!',
          ),
          const SizedBox(height: 20),

          // Sentences
          ...List.generate(_sentences.length, (i) => _buildSentenceTile(i)),
          const SizedBox(height: 16),

          // Word picker dropdown (shows when a tile is tapped)
          if (_activeSentence >= 0 && !_submitted) _buildWordPicker(),
          const SizedBox(height: 16),

          if (!_submitted)
            AnimatedOpacity(
              opacity: _allFilled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: ERNextButton(
                label: _allFilled ? '✓ Check My Answers' : 'Fill all blanks first...',
                color: const Color(0xFF8B5CF6),
                onTap: _allFilled ? _submit : () {},
              ),
            )
          else ...[
            _buildResultBanner(),
            const SizedBox(height: 14),
            ERNextButton(
              label: 'Submit Room',
              color: const Color(0xFF8B5CF6),
              onTap: _finish,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentenceTile(int i) {
    final s = _sentences[i];
    final ans = _userAnswers[i];
    final isActive = _activeSentence == i;
    final isCorrect = _submitted && ans == s['answer'];
    final isWrong = _submitted && ans != null && ans != s['answer'];

    Color borderColor = isActive ? const Color(0xFF8B5CF6) : Colors.white.withAlpha(40);
    Color bgColor = isActive ? const Color(0xFF8B5CF6).withAlpha(30) : Colors.white.withAlpha(12);
    if (isCorrect) { bgColor = ERColors.green.withAlpha(30); borderColor = ERColors.green; }
    if (isWrong) { bgColor = ERColors.red.withAlpha(30); borderColor = ERColors.red; }

    return GestureDetector(
      onTap: _submitted ? null : () => setState(() => _activeSentence = isActive ? -1 : i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect ? ERColors.green : isWrong ? ERColors.red : const Color(0xFF8B5CF6).withAlpha(80),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isCorrect ? '✓' : isWrong ? '✗' : '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${s['hint']}', style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${s['pre']}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: ans != null
                        ? (isCorrect ? ERColors.green.withAlpha(80) : isWrong ? ERColors.red.withAlpha(80) : const Color(0xFF8B5CF6).withAlpha(80))
                        : Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ans != null ? (isCorrect ? ERColors.green : isWrong ? ERColors.red : const Color(0xFF8B5CF6)) : Colors.white.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    ans ?? '  ___  ',
                    style: TextStyle(
                      color: ans != null ? Colors.white : Colors.white.withAlpha(60),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text('${s['post']}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            if (isActive && !_submitted) ...[
              const SizedBox(height: 6),
              Text('⬇ Tap a word below', style: TextStyle(color: const Color(0xFF8B5CF6).withAlpha(200), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordPicker() {
    final pool = _sentences[_activeSentence]['pool'] as List<String>;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1040),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withAlpha(120), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(60), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose the correct word:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: pool.map((w) {
              final isChosen = _userAnswers[_activeSentence] == w;
              return GestureDetector(
                onTap: () => _selectWord(_activeSentence, w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isChosen ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withAlpha(40),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                    boxShadow: isChosen ? [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(120), blurRadius: 10)] : null,
                  ),
                  child: Text(w, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBanner() {
    final perfect = _correct == _sentences.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: perfect ? ERColors.green.withAlpha(40) : ERColors.orange.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: perfect ? ERColors.green : ERColors.orange, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            perfect ? '🎉 Perfect Score! $_correct/${_sentences.length}' : '💪 $_correct/${_sentences.length} correct!',
            style: TextStyle(
              color: perfect ? ERColors.green : ERColors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
