import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SpeakingGameScreen extends StatefulWidget {
  const SpeakingGameScreen({super.key});
  @override
  State<SpeakingGameScreen> createState() => _SpeakingGameScreenState();
}

class _SpeakingGameScreenState extends State<SpeakingGameScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _showResult = false;
  bool _isCorrect = false;
  int _score = 0;
  int _wordIndex = 0;
  late AnimationController _micController;
  late AnimationController _waveController;
  late AnimationController _rippleController;
  late Animation<double> _micScale;
  late Animation<double> _rippleAnim;
  String _feedback = '';

  final List<Map<String, dynamic>> _words = [
    {'word': 'Hello', 'phonetic': '/həˈloʊ/', 'emoji': '👋', 'tip': 'Start with huh sound'},
    {'word': 'Beautiful', 'phonetic': '/ˈbjuːtɪfəl/', 'emoji': '🌸', 'tip': 'BYOO-tih-ful'},
    {'word': 'Pronunciation', 'phonetic': '/prəˌnʌnsiˈeɪʃən/', 'emoji': '🗣️', 'tip': 'pro-NUN-see-AY-shun'},
    {'word': 'English', 'phonetic': '/ˈɪŋɡlɪʃ/', 'emoji': '📚', 'tip': 'ING-glish'},
    {'word': 'Adventure', 'phonetic': '/ədˈventʃər/', 'emoji': '🗺️', 'tip': 'ad-VEN-chur'},
  ];

  final List<String> _feedbacks = [
    '🌟 Excellent pronunciation!',
    '✅ Very well done!',
    '👍 Great job! Keep it up!',
    '🎯 Almost perfect!',
    '🔥 Superb! You\'re a star!',
  ];

  @override
  void initState() {
    super.initState();
    _micController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _micScale = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _micController, curve: Curves.easeInOut));
    _rippleAnim = Tween<double>(begin: 0, end: 1).animate(_rippleController);
  }

  @override
  void dispose() {
    _micController.dispose();
    _waveController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _micController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _stopRecording();
    });
  }

  void _stopRecording() {
    _micController.stop();
    _micController.reset();
    final random = Random();
    final success = random.nextBool();
    setState(() {
      _isRecording = false;
      _isCorrect = success;
      _feedback = _feedbacks[random.nextInt(_feedbacks.length)];
      if (success) _score += 15;
      _showResult = true;
    });
  }

  void _nextWord() {
    setState(() {
      _showResult = false;
      _isRecording = false;
      _wordIndex = (_wordIndex + 1) % _words.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_wordIndex];
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.speakingColor.withValues(alpha: 0.15), AppColors.darkBg, AppColors.darkBg],
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
                      const Expanded(child: Text('🎤 Speaking Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.speakingColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.speakingColor.withValues(alpha: 0.4))),
                        child: Text('⭐ $_score', style: const TextStyle(color: AppColors.speakingColor, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Word card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.speakingColor.withValues(alpha: 0.2), AppColors.darkCard], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.speakingColor.withValues(alpha: 0.4), width: 2),
                          ),
                          child: Column(
                            children: [
                              // Mascot motivator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: AppColors.speakingColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                    child: const Row(
                                      children: [
                                        Text('🦊', style: TextStyle(fontSize: 20)),
                                        SizedBox(width: 8),
                                        Text('Say this word!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(word['emoji'] as String, style: const TextStyle(fontSize: 80)),
                              const SizedBox(height: 16),
                              Text(word['word'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: 2)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.speakingColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                child: Text(word['phonetic'] as String, style: const TextStyle(color: AppColors.speakingColor, fontWeight: FontWeight.w700, fontSize: 16)),
                              ),
                              const SizedBox(height: 12),
                              Text('💡 ${word['tip']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Dynamic wave when recording
                        _buildRecordingWave(),
                        const SizedBox(height: 30),
                        // Big mic button
                        GestureDetector(
                          onTap: _isRecording ? _stopRecording : _startRecording,
                          child: ScaleTransition(
                            scale: _micScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_isRecording) ...[
                                  AnimatedBuilder(
                                    animation: _rippleAnim,
                                    builder: (context, _) {
                                      return Container(
                                        width: 120 + _rippleAnim.value * 40,
                                        height: 120 + _rippleAnim.value * 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.speakingColor.withValues(alpha: 0.15 * (1 - _rippleAnim.value)),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                Container(
                                  width: 110, height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _isRecording ? AppColors.sunsetGradient : AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isRecording ? AppColors.speakingColor : AppColors.primaryPurple).withValues(alpha: 0.5),
                                        blurRadius: 30, spreadRadius: _isRecording ? 10 : 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 52),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRecording ? '🎙️ Recording... Tap to stop' : 'Tap the mic to speak',
                          style: TextStyle(color: _isRecording ? AppColors.speakingColor : Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        if (_showResult) ...[
                          const SizedBox(height: 24),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: (_isCorrect ? AppColors.accentGreen : AppColors.accentOrange).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: (_isCorrect ? AppColors.accentGreen : AppColors.accentOrange).withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              children: [
                                Text(_feedback, textAlign: TextAlign.center, style: TextStyle(color: _isCorrect ? AppColors.accentGreen : AppColors.accentOrange, fontWeight: FontWeight.w800, fontSize: 16)),
                                const SizedBox(height: 16),
                                // Score stars
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (i) => Icon(
                                    i < (_isCorrect ? 3 : 1) ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: AppColors.accentYellow, size: 32,
                                  )),
                                ),
                                const SizedBox(height: 16),
                                GradientButton(
                                  text: 'Next Word →',
                                  onPressed: _nextWord,
                                  gradient: _isCorrect ? AppColors.oceanGradient : AppColors.sunsetGradient,
                                  width: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(30, (i) {
              final phase = (i / 30) * 2 * pi;
              final height = _isRecording
                  ? (sin(_waveController.value * 2 * pi + phase).abs() * 50 + 5)
                  : 5.0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 5,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  gradient: _isRecording
                      ? const LinearGradient(colors: [AppColors.speakingColor, AppColors.accentPink], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                      : LinearGradient(colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
