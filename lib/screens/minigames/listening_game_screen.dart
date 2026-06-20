import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ListeningGameScreen extends StatefulWidget {
  const ListeningGameScreen({super.key});
  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _selectedAnswer = -1;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _score = 0;
  int _questionIndex = 0;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _questions = [
    {'emoji': '🐶', 'word': 'DOG', 'description': 'A domestic animal that barks', 'options': ['Cat', 'Dog', 'Bird', 'Fish'], 'correct': 1},
    {'emoji': '☀️', 'word': 'SUN', 'description': 'The star at center of our solar system', 'options': ['Moon', 'Star', 'Sun', 'Cloud'], 'correct': 2},
    {'emoji': '🍕', 'word': 'PIZZA', 'description': 'A popular Italian food', 'options': ['Burger', 'Pasta', 'Sushi', 'Pizza'], 'correct': 3},
    {'emoji': '🏖️', 'word': 'BEACH', 'description': 'Sandy shores next to ocean', 'options': ['Beach', 'Mountain', 'Forest', 'Desert'], 'correct': 0},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != -1) return;
    setState(() {
      _selectedAnswer = index;
      _isCorrect = index == _questions[_questionIndex]['correct'];
      if (_isCorrect) _score += 10;
      _showFeedback = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _selectedAnswer = -1;
      _isPlaying = false;
      _questionIndex = (_questionIndex + 1) % _questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_questionIndex];
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.listeningColor.withValues(alpha: 0.15), AppColors.darkBg, AppColors.darkBg],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('🎧 Listening Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.listeningColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.listeningColor.withValues(alpha: 0.4))),
                        child: Text('⭐ $_score', style: const TextStyle(color: AppColors.listeningColor, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Audio player card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.listeningColor.withValues(alpha: 0.25), AppColors.darkCard], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.listeningColor.withValues(alpha: 0.4), width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(q['emoji'] as String, style: const TextStyle(fontSize: 80)),
                              const SizedBox(height: 12),
                              Text('Listen and identify', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              // Sound wave visualization
                              _buildSoundWaves(),
                              const SizedBox(height: 24),
                              // Play button
                              ScaleTransition(
                                scale: _isPlaying ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                                child: GestureDetector(
                                  onTap: _togglePlay,
                                  child: Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _isPlaying ? AppColors.primaryGradient : AppColors.oceanGradient,
                                      boxShadow: [BoxShadow(color: AppColors.listeningColor.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: _isPlaying ? 5 : 0)],
                                    ),
                                    child: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(_isPlaying ? 'Playing...' : 'Tap to play', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                              if (_isPlaying) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(color: AppColors.listeningColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                  child: Text(q['description'] as String, textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('What did you hear?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        const SizedBox(height: 16),
                        // Answer options
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2),
                          itemCount: (q['options'] as List).length,
                          itemBuilder: (context, i) {
                            final correct = q['correct'] as int;
                            Color btnColor = AppColors.darkCard;
                            if (_selectedAnswer != -1) {
                              if (i == correct) {
                                btnColor = AppColors.accentGreen;
                              } else if (i == _selectedAnswer) btnColor = const Color(0xFFEF4444);
                            }
                            return GestureDetector(
                              onTap: () => _selectAnswer(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: btnColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _selectedAnswer != -1 && (i == correct || i == _selectedAnswer) ? btnColor : Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Center(child: Text((q['options'] as List)[i] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
                              ),
                            );
                          },
                        ),
                        if (_selectedAnswer != -1) ...[
                          const SizedBox(height: 20),
                          GradientButton(text: 'Next →', onPressed: _nextQuestion, gradient: AppColors.oceanGradient, width: double.infinity),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showFeedback)
            Positioned.fill(
              child: FeedbackOverlay(
                isCorrect: _isCorrect,
                message: _isCorrect ? '🎧 Great Ears! +10 XP' : '😅 Listen again!',
                onDismiss: () => setState(() => _showFeedback = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSoundWaves() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(20, (i) {
              final phase = (i / 20) * 2 * pi;
              final height = _isPlaying
                  ? (sin(_waveController.value * 2 * pi + phase).abs() * 40 + 8)
                  : (sin(phase).abs() * 15 + 5);
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.listeningColor, AppColors.primaryCyan],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
