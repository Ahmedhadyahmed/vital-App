import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateToHome();
  }

  void _initializeAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Slide animation for text
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Rotation animation for decorative elements
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );

    // Pulse animation for logo glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() {
    // Start background animations immediately
    _rotationController.repeat();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);

    // Stagger the main content animations
    Timer(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Timer(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });

    Timer(const Duration(milliseconds: 800), () {
      _slideController.forward();
    });
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D4F3C),
              Color(0xFF2D7A6B),
              Color(0xFF4FD1C7),
              Color(0xFF81E6D9),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedParticles(),

            // Rotating decorative circles
            _buildRotatingDecorations(),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with glow effect
                    _buildAnimatedLogo(),

                    const SizedBox(height: 32),

                    // Sliding text with shimmer effect
                    _buildAnimatedText(),

                    const SizedBox(height: 48),

                    // Loading indicator
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            ),

            // Floating particles overlay
            _buildFloatingParticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3 * _pulseAnimation.value),
                      blurRadius: 30 * _pulseAnimation.value,
                      spreadRadius: 10 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                        const Color(0xFF4FD1C7).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 60,
                    color: Color(0xFF0D4F3C),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE6FFFA)],
            ).createShader(bounds),
            child: const Text(
              'Vital App',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Health, Our Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRotatingDecorations() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Large rotating circle
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Medium rotating circle
            Positioned(
              bottom: -50,
              left: -50,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 0.7,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double animationOffset = (index / 15) * 2 * math.pi;
            final double radius = 50 + (index % 3) * 30;
            final double x = MediaQuery.of(context).size.width / 2 +
                radius * math.cos(_particleAnimation.value * 2 * math.pi + animationOffset);
            final double y = MediaQuery.of(context).size.height / 2 +
                radius * math.sin(_particleAnimation.value * 2 * math.pi + animationOffset);

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 4 + (index % 3) * 2,
                height: 4 + (index % 3) * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final double delay = index * 0.3;
            final double animValue = (_particleAnimation.value + delay) % 1.0;
            final double opacity = (math.sin(animValue * math.pi) * 0.5).abs();

            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height * animValue,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}