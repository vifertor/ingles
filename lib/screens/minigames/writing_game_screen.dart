import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class WritingGameScreen extends StatefulWidget {
  const WritingGameScreen({super.key});
  @override
  State<WritingGameScreen> createState() => _WritingGameScreenState();
}

class _WritingGameScreenState extends State<WritingGameScreen> with SingleTickerProviderStateMixin {
  int _gameMode = 0; // 0=scramble, 1=fill-blank, 2=type-word
  final List<String> _gameModes = ['Unscramble', 'Fill Blank', 'Type Word'];
  String _userInput = '';
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _score = 0;
  int _questionIndex = 0;

  final List<Map<String, dynamic>> _scrambleWords = [
    {'letters': ['A','P','P','L','E'], 'answer': 'APPLE', 'emoji': '🍎'},
    {'letters': ['H','O','U','S','E'], 'answer': 'HOUSE', 'emoji': '🏠'},
    {'letters': ['W','A','T','E','R'], 'answer': 'WATER', 'emoji': '💧'},
    {'letters': ['B','O','O','K'], 'answer': 'BOOK', 'emoji': '📚'},
  ];

  final List<Map<String, dynamic>> _fillBlanks = [
    {'sentence': 'The ___ is red.', 'answer': 'apple', 'options': ['apple', 'house', 'car', 'tree'], 'emoji': '🍎'},
    {'sentence': 'I ___ to school every day.', 'answer': 'go', 'options': ['go', 'eat', 'sleep', 'run'], 'emoji': '🏫'},
    {'sentence': 'She ___ a book.', 'answer': 'reads', 'options': ['reads', 'eats', 'drinks', 'sings'], 'emoji': '📖'},
  ];

  final List<Map<String, dynamic>> _typeWords = [
    {'emoji': '🍎', 'word': 'APPLE', 'hint': 'A red or green fruit'},
    {'emoji': '🐕', 'word': 'DOG', 'hint': "Man's best friend"},
    {'emoji': '☀️', 'word': 'SUN', 'hint': 'It gives us light'},
    {'emoji': '🌊', 'word': 'WAVE', 'hint': 'Movement of water'},
  ];

  List<String> _selectedLetters = [];

  @override
  void initState() {
    super.initState();
    _resetScramble();
  }

  void _resetScramble() {
    if (_questionIndex < _scrambleWords.length) {
      final w = _scrambleWords[_questionIndex];
      _selectedLetters = List<String>.from(w['letters'] as List<String>)..shuffle();
    }
  }

  void _checkAnswer(String answer, String correct) {
    setState(() {
      _isCorrect = answer.toLowerCase() == correct.toLowerCase();
      if (_isCorrect) _score += 10;
      _showFeedback = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _userInput = '';
      if (_questionIndex < 3) {
        _questionIndex++;
        _resetScramble();
      } else {
        _questionIndex = 0;
        _score = 0;
        _resetScramble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.writingColor.withValues(alpha: 0.15), AppColors.darkBg, AppColors.darkBg],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('✍️ Writing Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.writingColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.4))),
                        child: Text('⭐ $_score', style: const TextStyle(color: AppColors.writingColor, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                // Game mode tabs
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: List.generate(_gameModes.length, (i) {
                      final selected = i == _gameMode;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _gameMode = i; _questionIndex = 0; _userInput = ''; _resetScramble(); }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: selected ? AppColors.forestGradient : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_gameModes[i], textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: _gameMode == 1
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildGameContent(),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildGameContent(),
                        ),
                ),
              ],
            ),
          ),
          if (_showFeedback)
            Positioned.fill(
              child: FeedbackOverlay(
                isCorrect: _isCorrect,
                message: _isCorrect ? '🎉 Correct! +10 XP' : '😅 Keep trying!',
                onDismiss: _nextQuestion,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_gameMode) {
      case 0: return _buildScrambleGame();
      case 1: return _buildFillBlankGame();
      case 2: return _buildTypeWordGame();
      default: return _buildScrambleGame();
    }
  }

  Widget _buildScrambleGame() {
    final word = _scrambleWords[_questionIndex % _scrambleWords.length];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(word['emoji'] as String, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              Text('Unscramble the letters!', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
              const SizedBox(height: 20),
              // Answer display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.darkBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3))),
                child: Text(
                  _userInput.isEmpty ? '_ ' * (word['answer'] as String).length : _userInput,
                  style: TextStyle(color: _userInput.isEmpty ? Colors.white.withValues(alpha: 0.3) : Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4),
                ),
              ),
              const SizedBox(height: 24),
              // Scrambled letters
              Wrap(
                spacing: 10, runSpacing: 10,
                children: (word['letters'] as List<String>).asMap().entries.map((e) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (_userInput.length < (word['answer'] as String).length) {
                        _userInput += e.value;
                      }
                    }),
                    child: Container(
                      width: 48, height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.forestGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.writingColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text(e.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { if (_userInput.isNotEmpty) _userInput = _userInput.substring(0, _userInput.length - 1); }),
                      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.backspace_rounded, color: Colors.white60, size: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: GradientButton(
                      text: 'Check Answer',
                      onPressed: () => _checkAnswer(_userInput, word['answer'] as String),
                      gradient: AppColors.forestGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFillBlankGame() {
    final item = _fillBlanks[_questionIndex % _fillBlanks.length];
    int selected = -1;
    return StatefulBuilder(
      builder: (context, innerSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Question card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(item['emoji'] as String, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose the correct word to fill the blank:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['sentence'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Instruction label ──────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.writingColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Text('👇', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('Tap your answer below', style: TextStyle(color: AppColors.writingColor, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Answer options – visible without scrolling ─────────
            ...(item['options'] as List<String>).asMap().entries.map((e) {
              final isSelected = selected == e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    innerSetState(() => selected = e.key);
                    _checkAnswer(e.value, item['answer'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.writingColor.withValues(alpha: 0.2)
                          : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.writingColor
                            : Colors.white.withValues(alpha: 0.12),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.writingColor.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: 1)]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.writingColor
                                : AppColors.writingColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + e.key),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.writingColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          e.value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildTypeWordGame() {
    final item = _typeWords[_questionIndex % _typeWords.length];
    final controller = TextEditingController();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3))),
          child: Column(
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: AppColors.writingColor.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.writingColor.withValues(alpha: 0.3), width: 3)),
                child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 64))),
              ),
              const SizedBox(height: 16),
              Text(item['hint'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: 4),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '_ ' * (item['word'] as String).length,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), letterSpacing: 4, fontSize: 22),
                  filled: true, fillColor: AppColors.darkBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.writingColor, width: 2)),
                ),
                onChanged: (v) => setState(() => _userInput = v),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Submit Answer',
                onPressed: () => _checkAnswer(_userInput, item['word'] as String),
                gradient: AppColors.forestGradient,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
