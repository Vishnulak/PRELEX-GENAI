import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ParticleNetworkBackground extends StatefulWidget {
  @override
  _ParticleNetworkBackgroundState createState() =>
      _ParticleNetworkBackgroundState();
}

class _ParticleNetworkBackgroundState extends State<ParticleNetworkBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final int particleCount = 100;
  final double connectionDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100), // ~60 FPS
      vsync: this,
    )..repeat();

    particles = [];
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    if (particles.isEmpty) {
      final random = math.Random();
      for (int i = 0; i < particleCount; i++) {
        particles.add(Particle(
          x: random.nextDouble() * size.width,
          y: random.nextDouble() * size.height,
          vx: (random.nextDouble() - 0.5) * 0.5,
          vy: (random.nextDouble() - 0.5) * 0.5,
          size: random.nextDouble() * 3 + 1,
          opacity: random.nextDouble() * 0.8 + 0.2,
        ));
      }
    }
  }

  void _updateParticles() {
    // Use the actual screen size for particle bounds
    final size = MediaQuery.of(context).size;

    for (var particle in particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;

      // Bounce off edges
      if (particle.x <= 0 || particle.x >= size.width) {
        particle.vx *= -1;
      }
      if (particle.y <= 0 || particle.y >= size.height) {
        particle.vy *= -1;
      }

      // Keep particles within bounds
      particle.x = particle.x.clamp(0.0, size.width);
      particle.y = particle.y.clamp(0.0, size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the actual screen size
    final screenSize = MediaQuery.of(context).size;

    // Initialize particles with screen size
    _initializeParticles(screenSize);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF0A1A2A), // Dark blue center
            Color(0xFF051015), // Very dark edges
          ],
        ),
      ),
      child: CustomPaint(
        painter: ParticleNetworkPainter(
          particles: particles,
          connectionDistance: connectionDistance,
        ),
        size: screenSize,
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
}

class ParticleNetworkPainter extends CustomPainter {
  final List<Particle> particles;
  final double connectionDistance;

  ParticleNetworkPainter({
    required this.particles,
    required this.connectionDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections first (so they appear behind particles)
    _drawConnections(canvas);

    // Draw particles
    _drawParticles(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final connectionPaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final particle1 = particles[i];
        final particle2 = particles[j];

        final distance = math.sqrt(
          math.pow(particle1.x - particle2.x, 2) +
              math.pow(particle1.y - particle2.y, 2),
        );

        if (distance < connectionDistance) {
          final opacity = (1 - distance / connectionDistance) * 0.6;

          // Create gradient for the connection line
          final shader = ui.Gradient.linear(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            [
              Color(0xFF00FFB3).withOpacity(opacity),
              Color(0xFF14F195).withOpacity(opacity * 0.7),
              Color(0xFF00D4FF).withOpacity(opacity * 0.5),
            ],
            [0.0, 0.5, 1.0],
          );

          connectionPaint.shader = shader;

          canvas.drawLine(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            connectionPaint,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var particle in particles) {
      // Outer glow
      final glowPaint = Paint()
        ..color = Color(0xFF00FFB3).withOpacity(particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 3,
        glowPaint,
      );

      // Main particle with gradient
      final particlePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color(0xFF00FFB3).withOpacity(particle.opacity),
            Color(0xFF14F195).withOpacity(particle.opacity * 0.8),
            Color(0xFF00D4FF).withOpacity(particle.opacity * 0.6),
          ],
          stops: [0.0, 0.7, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(particle.x, particle.y),
            radius: particle.size,
          ),
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        particlePaint,
      );

      // Inner bright core
      final corePaint = Paint()
        ..color = Color(0xFFFFFFFF).withOpacity(particle.opacity * 0.9);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.3,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}

// Alternative version with more customization options
class CustomizableParticleNetwork extends StatefulWidget {
  final int particleCount;
  final double connectionDistance;
  final double particleSpeed;
  final List<Color> colors;
  final double maxParticleSize;

  const CustomizableParticleNetwork({
    Key? key,
    this.particleCount = 60,
    this.connectionDistance = 100.0,
    this.particleSpeed = 0.3,
    this.colors = const [
      Color(0xFF00FFB3),
      Color(0xFF14F195),
      Color(0xFF00D4FF),
    ],
    this.maxParticleSize = 4.0,
  }) : super(key: key);

  @override
  _CustomizableParticleNetworkState createState() =>
      _CustomizableParticleNetworkState();
}

class _CustomizableParticleNetworkState
    extends State<CustomizableParticleNetwork>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    particles = [];
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    if (particles.isEmpty) {
      final random = math.Random();
      for (int i = 0; i < widget.particleCount; i++) {
        particles.add(Particle(
          x: random.nextDouble() * size.width,
          y: random.nextDouble() * size.height,
          vx: (random.nextDouble() - 0.5) * widget.particleSpeed,
          vy: (random.nextDouble() - 0.5) * widget.particleSpeed,
          size: random.nextDouble() * widget.maxParticleSize + 1,
          opacity: random.nextDouble() * 0.8 + 0.2,
        ));
      }
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;

    for (var particle in particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;

      if (particle.x <= 0 || particle.x >= size.width) {
        particle.vx *= -1;
      }
      if (particle.y <= 0 || particle.y >= size.height) {
        particle.vy *= -1;
      }

      particle.x = particle.x.clamp(0.0, size.width);
      particle.y = particle.y.clamp(0.0, size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _initializeParticles(screenSize);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF0A1A2A),
            Color(0xFF051015),
          ],
        ),
      ),
      child: CustomPaint(
        painter: CustomizableParticleNetworkPainter(
          particles: particles,
          connectionDistance: widget.connectionDistance,
          colors: widget.colors,
        ),
        size: screenSize,
      ),
    );
  }
}

class CustomizableParticleNetworkPainter extends CustomPainter {
  final List<Particle> particles;
  final double connectionDistance;
  final List<Color> colors;

  CustomizableParticleNetworkPainter({
    required this.particles,
    required this.connectionDistance,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas);
    _drawParticles(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final connectionPaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final particle1 = particles[i];
        final particle2 = particles[j];

        final distance = math.sqrt(
          math.pow(particle1.x - particle2.x, 2) +
              math.pow(particle1.y - particle2.y, 2),
        );

        if (distance < connectionDistance) {
          final opacity = (1 - distance / connectionDistance) * 0.6;

          final shader = ui.Gradient.linear(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            colors.map((color) => color.withOpacity(opacity)).toList(),
          );

          connectionPaint.shader = shader;

          canvas.drawLine(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            connectionPaint,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var particle in particles) {
      // Glow effect
      final glowPaint = Paint()
        ..color = colors[0].withOpacity(particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 3,
        glowPaint,
      );

      // Main particle
      final particlePaint = Paint()
        ..shader = RadialGradient(
          colors: colors
              .map((color) => color.withOpacity(particle.opacity))
              .toList(),
        ).createShader(
          Rect.fromCircle(
            center: Offset(particle.x, particle.y),
            radius: particle.size,
          ),
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        particlePaint,
      );

      // Core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.9);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.3,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}