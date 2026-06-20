import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReadingGameScreen extends StatefulWidget {
  const ReadingGameScreen({super.key});
  @override
  State<ReadingGameScreen> createState() => _ReadingGameScreenState();
}

class _ReadingGameScreenState extends State<ReadingGameScreen>
    with SingleTickerProviderStateMixin {
  int _selectedAnswer = -1;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _score = 0;
  int _questionIndex = 0;
  late AnimationController _cardController;
  late Animation<double> _cardScale;

  final List<Map<String, dynamic>> _questions = [
    {'emoji': '🍎', 'question': 'What is this?', 'options': ['Apple', 'Dog', 'Chair', 'Book'], 'correct': 0},
    {'emoji': '🐕', 'question': 'What animal is this?', 'options': ['Cat', 'Fish', 'Dog', 'Bird'], 'correct': 2},
    {'emoji': '📚', 'question': 'What is this object?', 'options': ['Pen', 'Book', 'Table', 'Chair'], 'correct': 1},
    {'emoji': '🌳', 'question': 'What is this?', 'options': ['Flower', 'Tree', 'Grass', 'Rock'], 'correct': 1},
    {'emoji': '🏠', 'question': 'Where do people live?', 'options': ['School', 'Hospital', 'House', 'Market'], 'correct': 2},
  ];

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
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
      if (_questionIndex < _questions.length - 1) {
        _questionIndex++;
        _cardController.reset();
        _cardController.forward();
      } else {
        _questionIndex = 0;
        _score = 0;
      }
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
                colors: [AppColors.readingColor.withValues(alpha: 0.15), AppColors.darkBg, AppColors.darkBg],
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
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('📖 Reading Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.4)),
                        ),
                        child: Text('⭐ $_score', style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: List.generate(_questions.length, (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: i <= _questionIndex ? AppColors.oceanGradient : null,
                          color: i <= _questionIndex ? null : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _cardScale,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.readingColor.withValues(alpha: 0.2), AppColors.darkCard], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.readingColor.withValues(alpha: 0.3), width: 2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 140, height: 140,
                                  decoration: BoxDecoration(color: AppColors.readingColor.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.readingColor.withValues(alpha: 0.3), width: 3)),
                                  child: Center(child: Text(q['emoji'] as String, style: const TextStyle(fontSize: 72))),
                                ),
                                const SizedBox(height: 20),
                                Text(q['question'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
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
                                  border: Border.all(
                                    color: _selectedAnswer != -1 && (i == correct || i == _selectedAnswer)
                                        ? btnColor : Colors.white.withValues(alpha: 0.12),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text((q['options'] as List)[i] as String,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_selectedAnswer != -1) ...[
                          const SizedBox(height: 20),
                          GradientButton(
                            text: _questionIndex < _questions.length - 1 ? 'Next →' : '🎉 Finish!',
                            onPressed: _nextQuestion,
                            gradient: _isCorrect ? AppColors.oceanGradient : AppColors.sunsetGradient,
                            width: double.infinity,
                          ),
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
                message: _isCorrect ? '🎉 Excellent!\n+10 XP' : '😅 Keep going!',
                onDismiss: () => setState(() => _showFeedback = false),
              ),
            ),
        ],
      ),
    );
  }
}
