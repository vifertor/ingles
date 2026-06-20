import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/escape_room_provider.dart';
import 'er_widgets.dart';

/// ROOM 4 — FINAL PUZZLE
///
/// Displays the 4-character codes from Rooms 1, 2, 3 (already completed)
/// and reveals a random code for Room 4 itself (generated when this screen
/// is first entered, after which the user assembles the 4-char final code).
///
/// Final code formula:
///   [Room1 char 0] + [Room2 char 1] + [Room3 char 2] + [Room4 char 3]
class EscapeRoomRoom4 extends StatefulWidget {
  final VoidCallback onComplete;
  const EscapeRoomRoom4({super.key, required this.onComplete});

  @override
  State<EscapeRoomRoom4> createState() => _EscapeRoomRoom4State();
}

class _EscapeRoomRoom4State extends State<EscapeRoomRoom4>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  bool _wrong = false;
  bool _unlocked = false;

  late AnimationController _shakeCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _unlockCtrl;
  late AnimationController _celebrateCtrl;
  late AnimationController _wrongFlashCtrl;

  late Animation<double> _shakeAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _unlockScale;
  late Animation<double> _unlockOpacity;
  late Animation<double> _celebrateScale;

  /// Whether we've already recorded Room 4's own code in the provider.
  bool _r4CodeRegistered = false;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _unlockCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _celebrateCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _wrongFlashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -16.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -16.0, end: 16.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 16.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _unlockScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _unlockCtrl, curve: Curves.elasticOut));
    _unlockOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _unlockCtrl, curve: const Interval(0, 0.4)));
    _celebrateScale = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _celebrateCtrl, curve: Curves.easeInOut));

    // Generate + register Room 4's own code on first entry
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerR4Code());
  }

  /// Registers Room 4's own 4-char code in the provider (once).
  /// Room 4 is considered "attempted" with 1/1 so its code is always generated.
  void _registerR4Code() {
    if (_r4CodeRegistered) return;
    final provider = context.read<EscapeRoomProvider>();
    if (provider.progress.rooms['r4'] == null) {
      // completeRoom with 1/1 so isPassed = true and a code is generated
      provider.completeRoom('r4', 1, 1);
    }
    setState(() => _r4CodeRegistered = true);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _glowCtrl.dispose();
    _unlockCtrl.dispose();
    _celebrateCtrl.dispose();
    _wrongFlashCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _check() {
    final provider = context.read<EscapeRoomProvider>();
    if (provider.validateFinalCode(_ctrl.text)) {
      setState(() => _unlocked = true);
      _glowCtrl.stop();
      _unlockCtrl.forward();
    } else {
      setState(() => _wrong = true);
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _wrong = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _unlocked ? _buildSuccessScreen() : _buildPuzzleScreen();
  }

  // ══════════════════════════════════════════════════════════════════
  // PUZZLE SCREEN
  // ══════════════════════════════════════════════════════════════════
  Widget _buildPuzzleScreen() {
    const accent = Color(0xFFFFB703);
    final provider = context.watch<EscapeRoomProvider>();
    final codes = provider.getAllCodes();

    // Room 4 code may not be ready on the very first frame
    final r4Code = codes['r4'] ?? '????';

    return ERScaffold(
      topColor: const Color(0xFF0A0A1A),
      botColor: const Color(0xFF1A1500),
      roomLabel: '🔮 Final Puzzle — Combine the Codes!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar (always full for room 4)
          const ERProgress(current: 1, total: 1, color: accent),
          const SizedBox(height: 16),

          // Intro dialogue
          const DialogueScene(
            characterFace: '😨',
            characterBody: '📢',
            characterColor: accent,
            characterName: 'Airport Announcer',
            message:
                '🚨 FINAL ROOM! Each room gave you a 4-character code. Now combine ONE character from each code to unlock the vault and recover your passport!',
          ),
          const SizedBox(height: 20),

          // ── Code cards for all 4 rooms ──────────────────────────
          _RoomCodeCard(
            roomLabel: '📖  Room 1 — Vocabulary',
            code: codes['r1'] ?? '????',
            takePosition: 0,
            cardColor: const Color(0xFFFFB703),
          ),
          const SizedBox(height: 8),
          _RoomCodeCard(
            roomLabel: '✍️  Room 2 — Grammar',
            code: codes['r2'] ?? '????',
            takePosition: 1,
            cardColor: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 8),
          _RoomCodeCard(
            roomLabel: '🎧  Room 3 — Listening',
            code: codes['r3'] ?? '????',
            takePosition: 2,
            cardColor: const Color(0xFF56CFE1),
          ),
          const SizedBox(height: 8),
          _RoomCodeCard(
            roomLabel: '🔮  Room 4 — Final Puzzle',
            code: r4Code,
            takePosition: 3,
            cardColor: const Color(0xFFE63946),
          ),
          const SizedBox(height: 20),

          // ── Formula explanation ─────────────────────────────────
          _FormulaRow(
            r1Char: (codes['r1'] ?? '????').length > 0 ? codes['r1']![0] : '?',
            r2Char: (codes['r2'] ?? '????').length > 1 ? codes['r2']![1] : '?',
            r3Char: (codes['r3'] ?? '????').length > 2 ? codes['r3']![2] : '?',
            r4Char: r4Code.length > 3 ? r4Code[3] : '?',
          ),
          const SizedBox(height: 24),

          // ── Vault ───────────────────────────────────────────────
          _buildVault(accent),
          const SizedBox(height: 20),

          // ── Code input ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(_wrong ? _shakeAnim.value : 0, 0),
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _wrong ? ERColors.red : accent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: (_wrong ? ERColors.red : accent).withAlpha(80),
                    blurRadius: 16,
                  )
                ],
              ),
              child: TextField(
                controller: _ctrl,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.text,
                maxLength: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 16,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '_ _ _ _',
                  hintStyle: TextStyle(
                      color: Colors.white.withAlpha(50),
                      fontSize: 32,
                      letterSpacing: 14),
                  filled: true,
                  fillColor: const Color(0xFF0D1B2A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 22),
                ),
              ),
            ),
          ),
          if (_wrong) ...[
            const SizedBox(height: 8),
            const Text(
              '❌ Wrong code — check each highlighted character!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ERColors.red, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 20),
          ERNextButton(
              label: '🔓  Unlock the Passport!',
              onTap: _check,
              color: accent),
        ],
      ),
    );
  }

  Widget _buildVault(Color accent) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Center(
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D1B2A),
            border:
                Border.all(color: _wrong ? ERColors.red : accent, width: 4),
            boxShadow: [
              BoxShadow(
                color: (_wrong ? ERColors.red : accent)
                    .withAlpha((180 * _glowAnim.value).toInt()),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child:
              Text(_wrong ? '❌' : '🔒', style: const TextStyle(fontSize: 60)),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SUCCESS SCREEN
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2A0A), Color(0xFF0D4A0D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _unlockOpacity,
            child: ScaleTransition(
              scale: _unlockScale,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated passport
                    AnimatedBuilder(
                      animation: _celebrateScale,
                      builder: (_, child) => Transform.scale(
                        scale: _celebrateScale.value,
                        child: child,
                      ),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0D4A0D),
                          border:
                              Border.all(color: ERColors.accent, width: 4),
                          boxShadow: [
                            BoxShadow(
                                color: ERColors.accent.withAlpha(150),
                                blurRadius: 40,
                                spreadRadius: 10),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('📘',
                            style: TextStyle(fontSize: 80)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('🎉 🎊 🎉',
                        style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: ERColors.accent.withAlpha(120),
                              blurRadius: 30)
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'PASSPORT RECOVERED! ✈️',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0D1B2A),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You cracked the code and solved all 4 rooms! Your passport is back and your flight is saved! Have a great trip! 🌍',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF415A77),
                                fontSize: 14,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ERNextButton(
                      label: '🏆  See Final Results!',
                      onTap: widget.onComplete,
                      color: ERColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ROOM CODE CARD
// Shows the full 4-char code of a room, highlighting the character
// that must be taken for the final puzzle.
// ══════════════════════════════════════════════════════════════════
class _RoomCodeCard extends StatelessWidget {
  final String roomLabel;
  final String code;
  final int takePosition; // 0-indexed position to use in final code
  final Color cardColor;

  const _RoomCodeCard({
    required this.roomLabel,
    required this.code,
    required this.takePosition,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final chars = code.padRight(4, '?').split('');
    final ordinals = ['1st', '2nd', '3rd', '4th'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardColor.withAlpha(80), width: 1.5),
      ),
      child: Row(
        children: [
          // Room label
          Expanded(
            child: Text(
              roomLabel,
              style: TextStyle(
                color: cardColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 4 character boxes
          ...List.generate(4, (i) {
            final isHighlighted = i == takePosition;
            final ch = i < chars.length ? chars[i] : '?';
            return Container(
              margin: const EdgeInsets.only(left: 5),
              width: 36,
              height: 40,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? cardColor.withAlpha(60)
                    : Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isHighlighted
                      ? cardColor
                      : Colors.white.withAlpha(30),
                  width: isHighlighted ? 2 : 1,
                ),
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                            color: cardColor.withAlpha(100),
                            blurRadius: 10,
                            spreadRadius: 1)
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ch,
                    style: TextStyle(
                      color: isHighlighted ? cardColor : Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (isHighlighted)
                    Text(
                      ordinals[i],
                      style: TextStyle(
                          color: cardColor.withAlpha(200),
                          fontSize: 7,
                          fontWeight: FontWeight.w800),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// FORMULA ROW
// Visual equation showing how the final code is assembled.
// ══════════════════════════════════════════════════════════════════
class _FormulaRow extends StatelessWidget {
  final String r1Char;
  final String r2Char;
  final String r3Char;
  final String r4Char;

  const _FormulaRow({
    required this.r1Char,
    required this.r2Char,
    required this.r3Char,
    required this.r4Char,
  });

  @override
  Widget build(BuildContext context) {
    final chars = [r1Char, r2Char, r3Char, r4Char];
    final colors = [
      const Color(0xFFFFB703),
      const Color(0xFF8B5CF6),
      const Color(0xFF56CFE1),
      const Color(0xFFE63946),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Column(
        children: [
          const Text(
            '🔐  Your Final Code =',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(chars.length, (i) {
                return Row(
                  children: [
                    _FormulaChar(char: chars[i], color: colors[i]),
                    if (i < chars.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '+',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 22,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          // Result
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: ERColors.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ERColors.accent.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '=  ',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
                Text(
                  chars.join(),
                  style: const TextStyle(
                    color: ERColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaChar extends StatelessWidget {
  final String char;
  final Color color;

  const _FormulaChar({required this.char, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 58,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withAlpha(80), blurRadius: 10)
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(
            color: color, fontSize: 26, fontWeight: FontWeight.w900),
      ),
    );
  }
}
