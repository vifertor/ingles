import 'package:flutter/material.dart';
import 'er_widgets.dart';

// ══════════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════════
enum _Speaker { Alex, officer }

class _Scene {
  final _Speaker speaker;
  final String message;
  const _Scene({required this.speaker, required this.message});
}

// ══════════════════════════════════════════════════════════════════
// MAIN WIDGET
// ══════════════════════════════════════════════════════════════════
class EscapeRoomStory extends StatefulWidget {
  final VoidCallback onFinish;
  const EscapeRoomStory({super.key, required this.onFinish});

  @override
  State<EscapeRoomStory> createState() => _EscapeRoomStoryState();
}

class _EscapeRoomStoryState extends State<EscapeRoomStory>
    with SingleTickerProviderStateMixin {
  int _sceneIndex = 0;
  bool _canNext = false;

  static const List<_Scene> _scenes = [
    _Scene(
      speaker: _Speaker.Alex,
      message:
          "Hi! I'm Alex Rivera, a student like you. Today we were supposed to fly to an international English conference... ✈️ But when I arrived at the airport... the security guard said my PASSPORT IS MISSING! 😱 Oh no!",
    ),
    _Scene(
      speaker: _Speaker.officer,
      message:
          "Sorry Miss. You cannot board without a passport. Your passport was taken to the English Department. You must solve 4 challenges to get it back.",
    ),
    _Scene(
      speaker: _Speaker.Alex,
      message:
          'I just got an email! It says: "Your passport is locked behind 4 rooms. Solve VOCABULARY, GRAMMAR, LISTENING and the FINAL PUZZLE to escape."',
    ),
    _Scene(
      speaker: _Speaker.Alex,
      message:
          "OK! I need YOUR help! Let's solve the 4 rooms together and get my passport back before the flight leaves! Are you READY? 🚀",
    ),
  ];

  // ── Speaker meta ─────────────────────────────────────────────────
  static const _AlexColor = Color(0xFFFFB703);
  static const _officerColor = Color(0xFF6C9BCF);

  Color get _activeColor => _scenes[_sceneIndex].speaker == _Speaker.Alex
      ? _AlexColor
      : _officerColor;

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isAlex = scene.speaker == _Speaker.Alex;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────
          const _AirportBackground(),

          // ── Gradient overlay ────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xBB0D1B2A), Color(0xDD0A1220)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Progress bar + close
                _TopBar(
                  sceneIndex: _sceneIndex,
                  total: _scenes.length,
                  accentColor: _activeColor,
                ),
                const SizedBox(height: 6),

                // Characters + dialogue
                Expanded(
                  child: _StoryScene(
                    key: ValueKey(_sceneIndex),
                    scene: scene,
                    isAlex: isAlex,
                    AlexColor: _AlexColor,
                    officerColor: _officerColor,
                    onMessageDone: () => setState(() => _canNext = true),
                  ),
                ),

                // Next button
                AnimatedOpacity(
                  opacity: _canNext ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: ERNextButton(
                      label: _sceneIndex < _scenes.length - 1
                          ? '→  Continue'
                          : '🚀  Start the Mission!',
                      color: _activeColor,
                      onTap: _canNext
                          ? () {
                              if (_sceneIndex < _scenes.length - 1) {
                                setState(() {
                                  _sceneIndex++;
                                  _canNext = false;
                                });
                              } else {
                                widget.onFinish();
                              }
                            }
                          : () {},
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
}

// ══════════════════════════════════════════════════════════════════
// TOP BAR — close button + progress pills
// ══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final int sceneIndex;
  final int total;
  final Color accentColor;

  const _TopBar({
    required this.sceneIndex,
    required this.total,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Row(
        children: [
          // Close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(35)),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Pills
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                final filled = i <= sceneIndex;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: 5,
                    margin: EdgeInsets.only(right: i < total - 1 ? 5 : 0),
                    decoration: BoxDecoration(
                      color: filled ? accentColor : Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),

          // Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withAlpha(80)),
            ),
            child: Text(
              '${sceneIndex + 1} / $total',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// STORY SCENE — two character images + speech bubble
// ══════════════════════════════════════════════════════════════════
class _StoryScene extends StatefulWidget {
  final _Scene scene;
  final bool isAlex;
  final Color AlexColor;
  final Color officerColor;
  final VoidCallback onMessageDone;

  const _StoryScene({
    super.key,
    required this.scene,
    required this.isAlex,
    required this.AlexColor,
    required this.officerColor,
    required this.onMessageDone,
  });

  @override
  State<_StoryScene> createState() => _StorySceneState();
}

class _StorySceneState extends State<_StoryScene>
    with TickerProviderStateMixin {
  late AnimationController _bubbleCtrl;
  late AnimationController _charCtrl;
  late Animation<Offset> _bubbleSlide;
  late Animation<double> _bubbleFade;
  late Animation<double> _charScale;

  final GlobalKey<TypewriterTextState> _twKey = GlobalKey();
  bool _isTalking = true;

  @override
  void initState() {
    super.initState();

    _bubbleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _charCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _bubbleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeOut));
    _bubbleFade = Tween<double>(begin: 0.0, end: 1.0).animate(_bubbleCtrl);
    _charScale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _charCtrl, curve: Curves.easeOut));

    _bubbleCtrl.forward();
    _charCtrl.forward();
  }

  @override
  void dispose() {
    _bubbleCtrl.dispose();
    _charCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speakerColor = widget.isAlex ? widget.AlexColor : widget.officerColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Two character illustrations ─────────────────────────
          Expanded(
            flex: 5,
            child: ScaleTransition(
              scale: _charScale,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Alex Rivera — left
                  Expanded(
                    child: _CharacterSlot(
                      imagePath: 'assets/images/Alex.png',
                      name: 'Alex Rivera',
                      isActive: widget.isAlex,
                      isTalking: widget.isAlex && _isTalking,
                      nameColor: widget.AlexColor,
                      alignLeft: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Officer Carlos — right
                  Expanded(
                    child: _CharacterSlot(
                      imagePath: 'assets/images/officer_carlos.png',
                      name: 'Officer Carlos',
                      isActive: !widget.isAlex,
                      isTalking: !widget.isAlex && _isTalking,
                      nameColor: widget.officerColor,
                      alignLeft: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Speech bubble ───────────────────────────────────────
          Expanded(
            flex: 4,
            child: FadeTransition(
              opacity: _bubbleFade,
              child: SlideTransition(
                position: _bubbleSlide,
                child: _SpeechBubble(
                  speakerName: widget.isAlex ? 'Alex Rivera' : 'Officer Carlos',
                  speakerEmoji: widget.isAlex ? '🎒' : '🛡️',
                  speakerColor: speakerColor,
                  message: widget.scene.message,
                  twKey: _twKey,
                  bubbleOnLeft: widget.isAlex,
                  onDone: () {
                    setState(() => _isTalking = false);
                    widget.onMessageDone();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CHARACTER SLOT — image + talking indicator + name badge
// ══════════════════════════════════════════════════════════════════
class _CharacterSlot extends StatefulWidget {
  final String imagePath;
  final String name;
  final bool isActive;
  final bool isTalking;
  final Color nameColor;
  final bool alignLeft;

  const _CharacterSlot({
    required this.imagePath,
    required this.name,
    required this.isActive,
    required this.isTalking,
    required this.nameColor,
    required this.alignLeft,
  });

  @override
  State<_CharacterSlot> createState() => _CharacterSlotState();
}

class _CharacterSlotState extends State<_CharacterSlot>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -7)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isActive ? 1.0 : 0.38,
      duration: const Duration(milliseconds: 400),
      child: AnimatedScale(
        scale: widget.isActive ? 1.0 : 0.90,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _floatAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, widget.isActive ? _floatAnim.value : 0),
            child: child,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ── Talking dots indicator ────────────────────────
              if (widget.isTalking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _TalkingDots(color: widget.nameColor),
                ),

              // ── Character image ───────────────────────────────
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Soft radial glow behind active character
                    if (widget.isActive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                widget.nameColor.withAlpha(45),
                                Colors.transparent,
                              ],
                              radius: 0.75,
                            ),
                          ),
                        ),
                      ),

                    // Character image — wrapped in ShaderMask to fade
                    // any residual background into the app's dark color.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (Rect bounds) {
                          // Radial gradient: fully opaque in center,
                          // fades to transparent at edges so any white/
                          // checkered border disappears smoothly.
                          return RadialGradient(
                            center: const Alignment(0, 0.1),
                            radius: 0.72,
                            colors: const [
                              Colors.white, // opaque — show character
                              Colors.white, // opaque — show character
                              Colors.transparent, // fade outer edges
                            ],
                            stops: const [0.0, 0.62, 1.0],
                          ).createShader(bounds);
                        },
                        child: Container(
                          // Dark bg under the image so any corner pixel
                          // that peeks through is the right color.
                          color: const Color(0xFF0D1B2A),
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _FallbackAvatar(
                              name: widget.name,
                              color: widget.nameColor,
                              isActive: widget.isActive,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Name badge ────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.nameColor.withAlpha(230)
                      : Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isActive
                        ? widget.nameColor
                        : Colors.white.withAlpha(30),
                    width: 1.5,
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                              color: widget.nameColor.withAlpha(90),
                              blurRadius: 12)
                        ]
                      : [],
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: widget.isActive
                        ? Colors.white
                        : Colors.white.withAlpha(90),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TALKING DOTS — animated "..." indicator above speaker
// ══════════════════════════════════════════════════════════════════
class _TalkingDots extends StatefulWidget {
  final Color color;
  const _TalkingDots({required this.color});

  @override
  State<_TalkingDots> createState() => _TalkingDotsState();
}

class _TalkingDotsState extends State<_TalkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Stagger each dot
            final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
            final y = -6.0 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withAlpha(200),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// FALLBACK AVATAR — shown if image asset fails to load
// ══════════════════════════════════════════════════════════════════
class _FallbackAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final bool isActive;

  const _FallbackAvatar({
    required this.name,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name[0].toUpperCase();
    return Center(
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: color.withAlpha(isActive ? 50 : 20),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: color.withAlpha(isActive ? 160 : 50), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name == 'Alex' ? '👩' : '👮',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 8),
            Text(
              initial,
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SPEECH BUBBLE — speaker header + typewriter text
// ══════════════════════════════════════════════════════════════════
class _SpeechBubble extends StatelessWidget {
  final String speakerName;
  final String speakerEmoji;
  final Color speakerColor;
  final String message;
  final GlobalKey<TypewriterTextState> twKey;
  final bool bubbleOnLeft;
  final VoidCallback onDone;

  const _SpeechBubble({
    required this.speakerName,
    required this.speakerEmoji,
    required this.speakerColor,
    required this.message,
    required this.twKey,
    required this.bubbleOnLeft,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => twKey.currentState?.skipToEnd(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: bubbleOnLeft
                ? const Radius.circular(4)
                : const Radius.circular(20),
            topRight: bubbleOnLeft
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: speakerColor.withAlpha(75),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Speaker header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
              decoration: BoxDecoration(
                color: speakerColor,
                borderRadius: BorderRadius.only(
                  topLeft: bubbleOnLeft
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  topRight: bubbleOnLeft
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Text(speakerEmoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(
                    speakerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.volume_up_rounded,
                      color: Colors.white.withAlpha(170), size: 15),
                ],
              ),
            ),

            // ── Message ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: TypewriterText(
                  key: twKey,
                  text: message,
                  style: const TextStyle(
                    color: Color(0xFF1B263B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.65,
                  ),
                  letterDelay: const Duration(milliseconds: 27),
                  onDone: onDone,
                ),
              ),
            ),

            // ── Skip hint ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 14),
              child: Text(
                'Tap to skip ›',
                textAlign: TextAlign.end,
                style:
                    TextStyle(color: speakerColor.withAlpha(130), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// AIRPORT BACKGROUND — subtle painted terminal scene
// ══════════════════════════════════════════════════════════════════
class _AirportBackground extends StatelessWidget {
  const _AirportBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AirportBgPainter(),
      size: Size.infinite,
    );
  }
}

class _AirportBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.width, s.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C), Color(0xFF2A5F8A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // Stars
    final rng = _Rng(77);
    final starPaint = Paint()..color = Colors.white.withAlpha(100);
    for (int i = 0; i < 28; i++) {
      canvas.drawCircle(
        Offset(rng.next() * s.width, rng.next() * s.height * 0.45),
        rng.next() * 1.3 + 0.2,
        starPaint,
      );
    }

    // Terminal building — left
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.38, s.width * 0.32, s.height * 0.35),
      Paint()..color = const Color(0xFF152535),
    );
    // Windows — left building
    _drawWindows(canvas, 0.04, 0.42, 3, 3, s, const Color(0xFFFFD18044));

    // Terminal building — right
    canvas.drawRect(
      Rect.fromLTWH(
          s.width * 0.68, s.height * 0.34, s.width * 0.32, s.height * 0.39),
      Paint()..color = const Color(0xFF152535),
    );
    // Windows — right building
    _drawWindows(canvas, 0.70, 0.38, 3, 3, s, const Color(0xFFFFD18044));

    // Ground / floor
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.73, s.width, s.height * 0.27),
      Paint()..color = const Color(0xFF0E2030),
    );

    // Floor tiles
    final tilePaint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (double x = 0; x <= s.width; x += s.width / 5) {
      canvas.drawLine(
          Offset(x, s.height * 0.73), Offset(x, s.height), tilePaint);
    }
    for (double y = s.height * 0.73; y <= s.height; y += s.height * 0.07) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), tilePaint);
    }

    // Departure board (top center strip)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(s.width / 2, s.height * 0.33),
            width: s.width * 0.52,
            height: s.height * 0.055),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF0A1625),
    );
    // LED dots on board
    final ledPaint = Paint()..color = const Color(0xFF4FC3F7).withAlpha(110);
    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(s.width * 0.26 + i * s.width * 0.07, s.height * 0.33),
        2.2,
        ledPaint,
      );
    }
  }

  void _drawWindows(Canvas canvas, double startXFrac, double startYFrac,
      int cols, int rows, Size s, Color color) {
    final paint = Paint()..color = color;
    const ww = 0.055;
    const wh = 0.032;
    const gx = 0.085;
    const gy = 0.055;
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              s.width * (startXFrac + c * gx),
              s.height * (startYFrac + r * gy),
              s.width * ww,
              s.height * wh,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AirportBgPainter old) => false;
}

/// Tiny deterministic pseudo-random helper (no dart:math needed).
class _Rng {
  int _s;
  _Rng(this._s);
  double next() {
    _s = (_s * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_s & 0xFFFF) / 0xFFFF;
  }
}
