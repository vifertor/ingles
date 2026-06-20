import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import 'main_app_shell.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen>
    with TickerProviderStateMixin {
  int _selectedAvatarIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedStyleIndex = 0;
  late AnimationController _previewController;
  late Animation<double> _previewBounce;
  late Animation<double> _previewGlow;

  final List<Color> _bgColors = [
    AppColors.primaryPurple,
    AppColors.primaryBlue,
    AppColors.accentGreen,
    AppColors.accentOrange,
    AppColors.accentPink,
    AppColors.primaryCyan,
    AppColors.accentYellow,
    const Color(0xFF6D28D9),
  ];

  final List<String> _accessories = ['None', '🎩', '👑', '🎓', '🎮', '⚡', '🌟', '🎯'];
  final List<String> _frameStyles = ['Classic', 'Galaxy', 'Fire', 'Ice', 'Nature'];

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _previewBounce = Tween<double>(begin: 0, end: -16).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeInOut),
    );

    _previewGlow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  LinearGradient _getFrameGradient() {
    switch (_selectedStyleIndex) {
      case 1:
        return const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)]);
      case 2:
        return const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFFBBF24)]);
      case 3:
        return const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)]);
      case 4:
        return const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF84CC16)]);
      default:
        return AppColors.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatars = MockData.avatarOptions;
    final selectedAvatar = avatars[_selectedAvatarIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF2D1B69)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Your Hero',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Customize your adventure avatar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Avatar Preview
              AnimatedBuilder(
                animation: _previewController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _previewBounce.value),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow ring
                    AnimatedBuilder(
                      animation: _previewGlow,
                      builder: (context, _) {
                        return Container(
                          width: 155,
                          height: 155,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _bgColors[_selectedColorIndex]
                                    .withValues(alpha: _previewGlow.value),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _getFrameGradient(),
                        border: Border.all(
                          color: _bgColors[_selectedColorIndex].withValues(alpha: 0.7),
                          width: 3,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bgColors[_selectedColorIndex].withValues(alpha: 0.3),
                        ),
                        child: Center(
                          child: Text(
                            selectedAvatar['emoji'] as String,
                            style: const TextStyle(fontSize: 70),
                          ),
                        ),
                      ),
                    ),
                    // Accessory
                    if (_selectedStyleIndex > 0)
                      Positioned(
                        top: 0,
                        child: Text(
                          _accessories[_selectedStyleIndex],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Text(
                selectedAvatar['name'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              // Customization panels
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Choose Character'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatars.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final selected = i == _selectedAvatarIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAvatarIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryPurple.withValues(alpha: 0.3)
                                      : AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryPurple
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: selected ? 2.5 : 1,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryPurple
                                                .withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      avatars[i]['emoji'] as String,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                    if (selected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 20,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildSectionLabel('Color Theme'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(_bgColors.length, (i) {
                          final selected = i == _selectedColorIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColorIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _bgColors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: _bgColors[i].withValues(alpha: 0.6),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: selected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),
                      _buildSectionLabel('Frame & Accessory'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _accessories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final selected = i == _selectedStyleIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedStyleIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryPurple.withValues(alpha: 0.3)
                                      : AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryPurple
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _accessories[i],
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Confirm button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GradientButton(
                  text: '🚀 Start My Adventure!',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const MainAppShell(isTeacher: false),
                        transitionDuration: const Duration(milliseconds: 600),
                        transitionsBuilder: (_, anim, __, child) {
                          return FadeTransition(opacity: anim, child: child);
                        },
                      ),
                    );
                  },
                  width: double.infinity,
                  height: 60,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
