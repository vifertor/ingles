import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../providers/escape_room_provider.dart';
import 'er_widgets.dart';
import 'room_summary_screen.dart';

/// ROOM 3 — Listening: Answer multiple choice questions from audio
class EscapeRoomRoom3 extends StatefulWidget {
  final VoidCallback onComplete;
  const EscapeRoomRoom3({super.key, required this.onComplete});
  @override
  State<EscapeRoomRoom3> createState() => _EscapeRoomRoom3State();
}

class _EscapeRoomRoom3State extends State<EscapeRoomRoom3>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _revealed = false;
  bool _submitted = false;
  bool _showSummary = false;
  int _correct = 0;
  final List<int> _selectedOptions = [-1, -1, -1];

  late AudioPlayer _audioPlayer;
  late AnimationController _waveCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'What is the flight number?',
      'options': ['GA-201', 'GA-301', 'GB-301', 'LA-301'],
      'correct': 1,
    },
    {
      'q': 'Where should passengers with luggage go?',
      'options': ['Gate B7', 'Gate A1', 'Desk 3', 'Counter 5'],
      'correct': 2,
    },
    {
      'q': 'Which TWO documents are required?',
      'options': ['ID & Ticket', 'Passport & boarding pass', 'Visa & ID card', 'Club card & passport'],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(_pulseCtrl);
  }

  Future<void> _initAudio() async {
    // 1. Listen to streams first to capture immediate states
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _revealed = true;
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      });
    });

    _audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });

    // 2. Set asset with preloading
    try {
      await _audioPlayer.setAsset('assets/audio/announcement.mp3');
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isLoading) return;
    
    try {
      // Self-healing: if player is idle, reload asset
      if (_audioPlayer.processingState == ProcessingState.idle) {
        await _audioPlayer.setAsset('assets/audio/announcement.mp3');
      }

      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        setState(() {
          _revealed = true;
        });
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling play: $e');
    }
  }

  void _selectOpt(int qi, int oi) {
    if (_submitted) return;
    setState(() => _selectedOptions[qi] = oi);
  }

  void _submit() {
    int c = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedOptions[i] == _questions[i]['correct']) c++;
    }
    setState(() { _submitted = true; _correct = c; });
  }

  void _finish() {
    final provider = context.read<EscapeRoomProvider>();
    provider.completeRoom('r3', _correct, _questions.length);
    setState(() => _showSummary = true);
  }

  bool get _allAnswered => _selectedOptions.every((s) => s != -1);

  @override
  Widget build(BuildContext context) {
    if (_showSummary) {
      final provider = context.watch<EscapeRoomProvider>();
      final result = provider.progress.rooms['r3'];
      if (result == null) return const SizedBox.shrink();
      return RoomSummaryScreen(
        roomName: 'Room 3 — Listening',
        correct: result.correctAnswers,
        total: result.totalQuestions,
        code: result.code,
        codeContributionIndex: 2, // Room 3 → 3rd character
        isPassed: result.isPassed,
        onRetry: () {
          provider.retryRoom('r3');
          setState(() {
            _submitted = false;
            _showSummary = false;
            _revealed = false;
            _correct = 0;
            for(int i = 0; i < _selectedOptions.length; i++) {
              _selectedOptions[i] = -1;
            }
          });
          _audioPlayer.seek(Duration.zero);
        },
        onNext: widget.onComplete,
      );
    }

    return ERScaffold(
      topColor: const Color(0xFF100A20),
      botColor: const Color(0xFF1A1040),
      roomLabel: '🎧 Room 3 — Listening',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ERProgress(
            current: _submitted ? 3 : _selectedOptions.where((s) => s != -1).length,
            total: 3,
            color: const Color(0xFFA855F7),
          ),
          const SizedBox(height: 16),

          // Character
          DialogueScene(
            key: ValueKey('r3_${_submitted}_$_revealed'),
            characterFace: '😮',
            characterBody: '📢',
            characterColor: const Color(0xFFA855F7),
            characterName: 'Airport Announcer',
            message: _submitted
                ? (_correct == 3
                    ? 'Incredible! Perfect score! You have amazing listening skills! 🎉'
                    : 'You got $_correct out of 3. Press Play again and listen more carefully!')
                : _revealed
                    ? 'Answer the 3 questions below based on the audio. You can play it again!'
                    : 'A mysterious tape recorder was left here. Press PLAY to hear the airport announcement!',
          ),
          const SizedBox(height: 20),

          // Audio player
          _buildAudioPlayer(),
          const SizedBox(height: 16),

          // Content (shown after playing)
          if (_revealed) ...[
            const SizedBox(height: 10),

            // Questions
            ...List.generate(_questions.length, (i) => _buildQuestion(i)),
            const SizedBox(height: 16),

            if (!_submitted)
              AnimatedOpacity(
                opacity: _allAnswered ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: ERNextButton(
                  label: _allAnswered ? '✓ Submit Answers' : 'Answer all 3 questions first...',
                  color: const Color(0xFFA855F7),
                  onTap: _allAnswered ? _submit : () {},
                ),
              )
            else ...[
              _buildResultBanner(),
              const SizedBox(height: 14),
              ERNextButton(
                label: 'Submit Room',
                color: const Color(0xFFA855F7),
                onTap: _finish,
              ),
            ],
          ] else ...[
            // Before playing — decorative prompt
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('🎧', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text(
                    'Press PLAY to hear the\nairport announcement',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1040),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA855F7).withAlpha(120), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFA855F7).withAlpha(60), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Airport Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('Audio file', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              const Spacer(),
              // Play/Stop button
              ScaleTransition(
                scale: _isPlaying ? _pulse : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying ? ERColors.red : const Color(0xFFA855F7),
                      boxShadow: [BoxShadow(
                        color: (_isPlaying ? ERColors.red : const Color(0xFFA855F7)).withAlpha(120),
                        blurRadius: _isPlaying ? 20 : 10,
                        spreadRadius: _isPlaying ? 4 : 0,
                      )],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Sound wave visualizer
          _buildWave(),
          const SizedBox(height: 8),
          Text(
            _isLoading
                ? '⏳ Loading Audio...'
                : _isPlaying
                    ? '🔊 Playing... (Tap to Pause)'
                    : _revealed
                        ? '▶ Tap to Resume/Play'
                        : '▶ PRESS TO PLAY',
            style: TextStyle(color: Colors.white.withAlpha(120), fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWave() {
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (_, __) => SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(30, (i) {
            final h = _isPlaying
                ? (sin(_waveCtrl.value * 2 * pi + i * 0.45).abs() * 26 + 4).toDouble()
                : 4.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: 3.5, height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? Color.lerp(const Color(0xFFA855F7), const Color(0xFF60A5FA), i / 30)!
                    : Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuestion(int qi) {
    final q = _questions[qi];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFA855F7).withAlpha(80)),
                alignment: Alignment.center,
                child: Text('${qi + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (oi) {
            final isSelected = _selectedOptions[qi] == oi;
            final isCorrect = _submitted && oi == correct;
            final isWrong = _submitted && isSelected && oi != correct;

            Color bg = isSelected ? const Color(0xFFA855F7).withAlpha(50) : Colors.white.withAlpha(8);
            Color border = isSelected ? const Color(0xFFA855F7) : Colors.white.withAlpha(25);
            if (isCorrect) { bg = ERColors.green.withAlpha(50); border = ERColors.green; }
            if (isWrong) { bg = ERColors.red.withAlpha(50); border = ERColors.red; }

            return GestureDetector(
              onTap: () => _selectOpt(qi, oi),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect ? ERColors.green : isWrong ? ERColors.red : isSelected ? const Color(0xFFA855F7) : Colors.transparent,
                        border: Border.all(color: border),
                      ),
                      alignment: Alignment.center,
                      child: isSelected || isCorrect || isWrong
                          ? Icon(isCorrect ? Icons.check : isWrong ? Icons.close : Icons.circle, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(options[oi], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultBanner() {
    final perfect = _correct == _questions.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: perfect ? ERColors.green.withAlpha(40) : ERColors.orange.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: perfect ? ERColors.green : ERColors.orange, width: 2),
      ),
      child: Center(
        child: Text(
          perfect ? '🎉 Perfect! $_correct/${_questions.length}' : '💪 $_correct/${_questions.length} correct!',
          style: TextStyle(
            color: perfect ? ERColors.green : ERColors.orange,
            fontWeight: FontWeight.w900, fontSize: 16,
          ),
        ),
      ),
    );
  }
}
