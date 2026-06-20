import 'package:flutter/material.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════
// ER COLORS
// ══════════════════════════════════════════════════════════════════
class ERColors {
  static const Color darkBlue = Color(0xFF1B263B);
  static const Color midBlue = Color(0xFF415A77);
  static const Color lightBlue = Color(0xFF778DA9);
  static const Color cream = Color(0xFFE0E1DD);
  static const Color accent = Color(0xFFFFB703);
  static const Color green = Color(0xFF56CFE1);
  static const Color red = Color(0xFFE63946);
  static const Color orange = Color(0xFFF4A261);
}

// ══════════════════════════════════════════════════════════════════
// TALKING CHARACTER — animated mouth open/close + body bounce
// ══════════════════════════════════════════════════════════════════
class TalkingCharacter extends StatefulWidget {
  final String face;       // emoji for the head/face
  final String body;       // emoji for body/outfit
  final Color bubbleColor;
  final double size;
  final bool isTalking;    // controls mouth animation
  final bool isFloating;   // body bob animation

  const TalkingCharacter({
    super.key,
    required this.face,
    required this.body,
    this.bubbleColor = const Color(0xFFFFB703),
    this.size = 80,
    this.isTalking = false,
    this.isFloating = true,
  });

  @override
  State<TalkingCharacter> createState() => _TalkingCharacterState();
}

class _TalkingCharacterState extends State<TalkingCharacter>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _mouthCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _bounceCtrl;

  late Animation<double> _floatAnim;
  late Animation<double> _mouthAnim;
  late Animation<double> _bounceAnim;

  bool _eyeOpen = true;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _mouthCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _mouthAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mouthCtrl, curve: Curves.easeInOut));
    _bounceAnim = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));

    // Random blinking
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    await Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
    if (!mounted) return;
    setState(() => _eyeOpen = false);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _eyeOpen = true);
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(TalkingCharacter old) {
    super.didUpdateWidget(old);
    if (widget.isTalking && !old.isTalking) {
      _mouthCtrl.repeat(reverse: true);
      _bounceCtrl.forward(from: 0);
    } else if (!widget.isTalking && old.isTalking) {
      _mouthCtrl.stop();
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _mouthCtrl.dispose();
    _blinkCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, _mouthAnim, _bounceAnim]),
      builder: (_, __) {
        final floatOffset = widget.isFloating ? _floatAnim.value : 0.0;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: _bounceAnim.value,
            child: _buildCharacter(),
          ),
        );
      },
    );
  }

  Widget _buildCharacter() {
    final s = widget.size;
    return CustomPaint(
      size: Size(s, s * 1.5),
      painter: _CharacterPainter(
        faceEmoji: widget.face,
        bodyEmoji: widget.body,
        bubbleColor: widget.bubbleColor,
        mouthOpen: widget.isTalking ? _mouthAnim.value : 0,
        eyeOpen: _eyeOpen,
        size: s,
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final String faceEmoji;
  final String bodyEmoji;
  final Color bubbleColor;
  final double mouthOpen;
  final bool eyeOpen;
  final double size;

  _CharacterPainter({
    required this.faceEmoji,
    required this.bodyEmoji,
    required this.bubbleColor,
    required this.mouthOpen,
    required this.eyeOpen,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final headR = size * 0.4;
    final headY = headR + 4;

    // Glow behind head
    final glowPaint = Paint()
      ..color = bubbleColor.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, headY), headR + 12, glowPaint);

    // Head circle
    final headPaint = Paint()..color = const Color(0xFFFFD6A5);
    canvas.drawCircle(Offset(cx, headY), headR, headPaint);

    // Head border
    final borderPaint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(cx, headY), headR, borderPaint);

    // Eyes
    final eyeY = headY - headR * 0.15;
    final eyeX = cx - headR * 0.3;
    _drawEye(canvas, Offset(eyeX, eyeY), headR * 0.18, eyeOpen);
    _drawEye(canvas, Offset(cx + headR * 0.3, eyeY), headR * 0.18, eyeOpen);

    // Mouth
    final mouthY = headY + headR * 0.3;
    final mouthW = headR * 0.5;
    final openAmount = mouthOpen * headR * 0.25;
    final mouthPaint = Paint()..color = const Color(0xFF8B4513);

    if (openAmount < 2) {
      // Closed mouth — smile arc
      final smilePath = Path()
        ..moveTo(cx - mouthW / 2, mouthY)
        ..quadraticBezierTo(cx, mouthY + headR * 0.15, cx + mouthW / 2, mouthY);
      canvas.drawPath(smilePath, mouthPaint..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    } else {
      // Open mouth
      final mouthRect = Rect.fromCenter(
        center: Offset(cx, mouthY + openAmount / 2),
        width: mouthW + openAmount,
        height: openAmount * 1.2,
      );
      canvas.drawOval(mouthRect, mouthPaint..style = PaintingStyle.fill);
      // Teeth
      final teethPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, mouthY + 2), width: mouthW * 0.8, height: openAmount * 0.4),
        teethPaint,
      );
    }

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF9999).withAlpha(140);
    canvas.drawCircle(Offset(cx - headR * 0.55, headY + headR * 0.1), headR * 0.2, cheekPaint);
    canvas.drawCircle(Offset(cx + headR * 0.55, headY + headR * 0.1), headR * 0.2, cheekPaint);

    // Body
    final bodyY = headY + headR + 6;
    final bodyW = size * 0.65;
    final bodyH = size * 0.55;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, bodyY + bodyH / 2), width: bodyW, height: bodyH),
      const Radius.circular(16),
    );
    final bodyPaint = Paint()..color = bubbleColor;
    canvas.drawRRect(bodyRect, bodyPaint);

    // Body border
    canvas.drawRRect(bodyRect, borderPaint..color = bubbleColor.withAlpha(180)..strokeWidth = 2);

    // Emoji on shirt
    final tp = TextPainter(
      text: TextSpan(text: bodyEmoji, style: TextStyle(fontSize: headR * 0.65)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, bodyY + bodyH * 0.2));
  }

  void _drawEye(Canvas canvas, Offset center, double radius, bool open) {
    final whitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF2C1810);
    canvas.drawCircle(center, radius, whitePaint);
    if (open) {
      canvas.drawCircle(center + Offset(radius * 0.1, radius * 0.1), radius * 0.55, pupilPaint);
      // Shine
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(center + Offset(radius * -0.15, radius * -0.2), radius * 0.22, shinePaint);
    } else {
      // Blink — just a line
      final blinkPaint = Paint()
        ..color = const Color(0xFF2C1810)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center - Offset(radius * 0.7, 0),
        center + Offset(radius * 0.7, 0),
        blinkPaint,
      );
    }
    // Eyelid outline
    final lidPaint = Paint()
      ..color = const Color(0xFF8B6F4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, lidPaint);
  }

  @override
  bool shouldRepaint(_CharacterPainter old) =>
      old.mouthOpen != mouthOpen || old.eyeOpen != eyeOpen;
}

// ══════════════════════════════════════════════════════════════════
// TYPEWRITER TEXT — text appears letter by letter
// ══════════════════════════════════════════════════════════════════
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration letterDelay;
  final VoidCallback? onDone;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.letterDelay = const Duration(milliseconds: 35),
    this.onDone,
  });

  @override
  State<TypewriterText> createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  String _displayed = '';
  int _index = 0;
  bool _done = false;
  bool _isSkipping = false;

  bool get isDone => _done;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(TypewriterText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _displayed = '';
      _index = 0;
      _done = false;
      _isSkipping = false;
      _start();
    }
  }

  void _start() async {
    while (_index < widget.text.length && !_isSkipping) {
      await Future.delayed(widget.letterDelay);
      if (!mounted) return;
      if (_isSkipping) break;
      setState(() {
        _displayed += widget.text[_index];
        _index++;
      });
    }
    if (!mounted || _done) return;
    setState(() => _done = true);
    widget.onDone?.call();
  }

  void skipToEnd() {
    if (_done) return;
    setState(() {
      _isSkipping = true;
      _displayed = widget.text;
      _done = true;
    });
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style);
  }
}

// ══════════════════════════════════════════════════════════════════
// DIALOGUE SCENE — full talking scene with character + bubble
// ══════════════════════════════════════════════════════════════════
class DialogueScene extends StatefulWidget {
  final String characterFace;
  final String characterBody;
  final Color characterColor;
  final String characterName;
  final String message;
  final String bgGradientTop;
  final String bgGradientBot;
  final VoidCallback? onMessageDone;

  const DialogueScene({
    super.key,
    required this.characterFace,
    required this.characterBody,
    required this.characterColor,
    required this.characterName,
    required this.message,
    this.bgGradientTop = '#0D1B2A',
    this.bgGradientBot = '#1B263B',
    this.onMessageDone,
  });

  @override
  State<DialogueScene> createState() => _DialogueSceneState();
}

class _DialogueSceneState extends State<DialogueScene>
    with SingleTickerProviderStateMixin {
  bool _isTalking = true;
  final GlobalKey<TypewriterTextState> _twKey = GlobalKey();

  late AnimationController _entryCtrl;
  late Animation<double> _entryScale;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entryScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void didUpdateWidget(DialogueScene old) {
    super.didUpdateWidget(old);
    if (old.message != widget.message) {
      setState(() => _isTalking = true);
      _entryCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character
        ScaleTransition(
          scale: _entryScale,
          child: TalkingCharacter(
            face: widget.characterFace,
            body: widget.characterBody,
            bubbleColor: widget.characterColor,
            size: 90,
            isTalking: _isTalking,
          ),
        ),
        const SizedBox(height: 6),
        // Name tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: widget.characterColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: widget.characterColor.withAlpha(120), blurRadius: 10),
            ],
          ),
          child: Text(
            widget.characterName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Speech bubble
        SlideTransition(
          position: _entrySlide,
          child: GestureDetector(
            onTap: () => _twKey.currentState?.skipToEnd(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: widget.characterColor.withAlpha(60), blurRadius: 16, offset: const Offset(0, 4)),
                  const BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: TypewriterText(
                key: _twKey,
                text: widget.message,
                style: const TextStyle(
                  color: Color(0xFF1B263B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
                letterDelay: const Duration(milliseconds: 30),
                onDone: () {
                  setState(() => _isTalking = false);
                  widget.onMessageDone?.call();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Tap hint
        Text(
          'Tap bubble to skip ›',
          style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 11),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ER PROGRESS BAR
// ══════════════════════════════════════════════════════════════════
class ERProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const ERProgress({super.key, required this.current, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) => Expanded(
        child: Container(
          height: 6,
          margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
          decoration: BoxDecoration(
            color: i < current ? color : Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ER NEXT BUTTON
// ══════════════════════════════════════════════════════════════════
class ERNextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ERNextButton({super.key, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? ERColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c, Color.lerp(c, Colors.orange, 0.35)!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: c.withAlpha(100), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ER SCAFFOLD (portrait, gradient background)
// ══════════════════════════════════════════════════════════════════
class ERScaffold extends StatelessWidget {
  final Widget child;
  final Color topColor;
  final Color botColor;
  final String? roomLabel;

  const ERScaffold({
    super.key,
    required this.child,
    this.topColor = const Color(0xFF0D1B2A),
    this.botColor = const Color(0xFF1B263B),
    this.roomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [topColor, botColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (roomLabel != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(roomLabel!, style: TextStyle(color: Colors.white.withAlpha(180), fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
