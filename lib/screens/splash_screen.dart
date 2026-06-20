import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _floatController;
  late AnimationController _loadController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _floatAnim;
  late Animation<double> _loadAnim;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _floatAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _loadAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _loadController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _floatController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF2D1B69)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Floating stars background
            ..._buildStars(),
            // Floating clouds
            _buildCloud(
              top: 80,
              left: 20,
              size: 60,
              color: AppColors.primaryCyan.withValues(alpha: 0.15),
            ),
            _buildCloud(
              top: 150,
              right: 30,
              size: 80,
              color: AppColors.primaryPurple.withValues(alpha: 0.15),
            ),
            _buildCloud(
              bottom: 200,
              left: 40,
              size: 50,
              color: AppColors.accentYellow.withValues(alpha: 0.1),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mascot / Logo area
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Column(
                          children: [
                            // Mascot character
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple
                                        .withValues(alpha: 0.6),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child:
                                    Text('🦊', style: TextStyle(fontSize: 72)),
                              ),
                            ),
                            const SizedBox(height: 28),
                            // App name
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: const Text(
                                'Gamelish',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '✨ Learn English Through Adventure ✨',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: AnimatedBuilder(
                      animation: _loadAnim,
                      builder: (context, _) {
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _loadAnim.value,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getLoadingText(_loadAnim.value),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Version tag
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0 • Made with ❤️ for learners',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.3) return 'Loading worlds...';
    if (progress < 0.6) return 'Preparing missions...';
    if (progress < 0.85) return 'Waking up your avatar...';
    return 'Ready!';
  }

  List<Widget> _buildStars() {
    final Random rng = Random(42);
    return List.generate(30, (i) {
      final size = rng.nextDouble() * 4 + 2;
      final opacity = rng.nextDouble() * 0.6 + 0.2;
      return Positioned(
        top: rng.nextDouble() * 800,
        left: rng.nextDouble() * 400,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: opacity * 0.5),
                blurRadius: size * 2,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCloud({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, _) {
        return Positioned(
          top: top != null ? top + _floatAnim.value * 0.5 : null,
          bottom: bottom != null ? bottom - _floatAnim.value * 0.5 : null,
          left: left,
          right: right,
          child: Container(
            width: size * 1.5,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        );
      },
    );
  }
}
