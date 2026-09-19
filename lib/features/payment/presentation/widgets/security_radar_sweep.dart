import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';

enum SecurityRadarMode { scanning, monitoring, blocked, unavailable, resolved }

class SecurityRadarSweep extends StatefulWidget {
  const SecurityRadarSweep({required this.mode, super.key});

  final SecurityRadarMode mode;

  @override
  State<SecurityRadarSweep> createState() => _SecurityRadarSweepState();
}

class _SecurityRadarSweepState extends State<SecurityRadarSweep>
    with SingleTickerProviderStateMixin {
  static const _rotationPeriod = Duration(milliseconds: 3000);
  static const _settleDuration = Duration(milliseconds: 500);
  static const _staticPhase = 0.125;

  late final AnimationController _controller;
  final _phase = _RadarPhase(_staticPhase);
  bool _animationsDisabled = false;
  bool _scanningAnimationActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _rotationPeriod);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled = MediaQuery.disableAnimationsOf(context);
    _synchronizeAnimation();
  }

  @override
  void didUpdateWidget(covariant SecurityRadarSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _synchronizeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;
    final colors = _RadarColors.forMode(
      widget.mode,
      tokens: tokens,
      colorScheme: theme.colorScheme,
    );

    return ExcludeSemantics(
      child: SizedBox(
        width: double.infinity,
        height: 112,
        child: AnimatedSwitcher(
          duration: _animationsDisabled ? Duration.zero : _settleDuration,
          switchInCurve: tokens.motionCurve,
          switchOutCurve: tokens.motionCurve,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: DecoratedBox(
            key: ValueKey(widget.mode),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(tokens.controlRadius),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _SecurityRadarBackdropPainter(colors: colors),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _SecurityRadarSweepPainter(
                      animation: _controller,
                      phase: _phase,
                      mode: widget.mode,
                      colors: colors,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _synchronizeAnimation() {
    if (_animationsDisabled) {
      _scanningAnimationActive = false;
      _controller
        ..stop()
        ..value = 0;
      _phase.value = _staticPhase;
      return;
    }

    if (widget.mode == SecurityRadarMode.scanning) {
      if (_scanningAnimationActive) {
        return;
      }
      _scanningAnimationActive = true;
      _preserveCurrentPhase();
      _controller.repeat();
      return;
    }

    if (!_scanningAnimationActive) {
      return;
    }

    _scanningAnimationActive = false;
    _preserveCurrentPhase();
    _controller.animateTo(
      0.1,
      duration: _settleDuration,
      curve: Curves.easeOutSine,
    );
  }

  void _preserveCurrentPhase() {
    final controllerValue = _controller.value;
    _controller.stop();
    _phase.value = (_phase.value + controllerValue) % 1;
    _controller.value = 0;
  }
}

final class _RadarColors {
  const _RadarColors({
    required this.background,
    required this.border,
    required this.staticStroke,
    required this.shieldStroke,
    required this.activeStroke,
  });

  factory _RadarColors.forMode(
    SecurityRadarMode mode, {
    required TenantDesignTokens tokens,
    required ColorScheme colorScheme,
  }) {
    final statusStroke = switch (mode) {
      SecurityRadarMode.blocked => tokens.securityErrorForeground,
      SecurityRadarMode.monitoring ||
      SecurityRadarMode.resolved => Colors.green.shade700,
      SecurityRadarMode.unavailable => colorScheme.secondary,
      SecurityRadarMode.scanning => tokens.accent,
    };
    final statusTint = switch (mode) {
      SecurityRadarMode.blocked => tokens.securityErrorBackground.withAlpha(
        170,
      ),
      SecurityRadarMode.monitoring ||
      SecurityRadarMode.resolved => Colors.green.shade700.withAlpha(24),
      SecurityRadarMode.unavailable =>
        colorScheme.surfaceContainerHigh.withAlpha(120),
      SecurityRadarMode.scanning => Colors.transparent,
    };

    return _RadarColors(
      background: Color.alphaBlend(statusTint, tokens.accentContainer),
      border: tokens.accent.withAlpha(112),
      staticStroke: tokens.accent.withAlpha(118),
      shieldStroke: tokens.accent.withAlpha(210),
      activeStroke: statusStroke,
    );
  }

  final Color background;
  final Color border;
  final Color staticStroke;
  final Color shieldStroke;
  final Color activeStroke;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RadarColors &&
          background == other.background &&
          border == other.border &&
          staticStroke == other.staticStroke &&
          shieldStroke == other.shieldStroke &&
          activeStroke == other.activeStroke;

  @override
  int get hashCode =>
      Object.hash(background, border, staticStroke, shieldStroke, activeStroke);
}

final class _SecurityRadarBackdropPainter extends CustomPainter {
  _SecurityRadarBackdropPainter({required this.colors});

  final _RadarColors colors;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _shieldPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeJoin = StrokeJoin.round;

  Size? _cachedSize;
  Offset _center = Offset.zero;
  double _radius = 0;
  Path _shieldPath = Path();

  @override
  void paint(Canvas canvas, Size size) {
    _ensureGeometry(size);

    _linePaint.color = colors.staticStroke;
    for (final scale in const [0.34, 0.67, 1.0]) {
      canvas.drawCircle(_center, _radius * scale, _linePaint);
    }

    canvas
      ..drawLine(
        Offset(_center.dx - _radius, _center.dy),
        Offset(_center.dx + _radius, _center.dy),
        _linePaint,
      )
      ..drawLine(
        Offset(_center.dx, _center.dy - _radius),
        Offset(_center.dx, _center.dy + _radius),
        _linePaint,
      );

    _shieldPaint.color = colors.shieldStroke;
    canvas.drawPath(_shieldPath, _shieldPaint);
  }

  @override
  bool shouldRepaint(covariant _SecurityRadarBackdropPainter oldDelegate) =>
      oldDelegate.colors != colors;

  void _ensureGeometry(Size size) {
    if (_cachedSize == size) {
      return;
    }

    _cachedSize = size;
    _center = Offset(size.width / 2, size.height / 2);
    _radius = math.min(size.height * 0.4, size.width * 0.2);
    final shieldWidth = _radius * 0.92;
    final shieldHeight = _radius * 1.18;
    final top = _center.dy - shieldHeight * 0.52;
    final bottom = _center.dy + shieldHeight * 0.54;

    _shieldPath = Path()
      ..moveTo(_center.dx, top)
      ..cubicTo(
        _center.dx - shieldWidth * 0.2,
        top + shieldHeight * 0.13,
        _center.dx - shieldWidth * 0.5,
        top + shieldHeight * 0.18,
        _center.dx - shieldWidth * 0.5,
        top + shieldHeight * 0.18,
      )
      ..lineTo(_center.dx - shieldWidth * 0.43, bottom - shieldHeight * 0.32)
      ..cubicTo(
        _center.dx - shieldWidth * 0.34,
        bottom - shieldHeight * 0.12,
        _center.dx - shieldWidth * 0.14,
        bottom,
        _center.dx,
        bottom,
      )
      ..cubicTo(
        _center.dx + shieldWidth * 0.14,
        bottom,
        _center.dx + shieldWidth * 0.34,
        bottom - shieldHeight * 0.12,
        _center.dx + shieldWidth * 0.43,
        bottom - shieldHeight * 0.32,
      )
      ..lineTo(_center.dx + shieldWidth * 0.5, top + shieldHeight * 0.18)
      ..cubicTo(
        _center.dx + shieldWidth * 0.5,
        top + shieldHeight * 0.18,
        _center.dx + shieldWidth * 0.2,
        top + shieldHeight * 0.13,
        _center.dx,
        top,
      )
      ..close();
  }
}

final class _SecurityRadarSweepPainter extends CustomPainter {
  _SecurityRadarSweepPainter({
    required Animation<double> animation,
    required this.phase,
    required this.mode,
    required this.colors,
  }) : _animation = animation,
       super(repaint: animation);

  static const _beamWidth = math.pi * 0.42;
  static const _nodes = [
    Offset(-0.62, -0.18),
    Offset(-0.42, 0.48),
    Offset(-0.18, -0.63),
    Offset(0.13, 0.31),
    Offset(0.34, -0.42),
    Offset(0.58, 0.18),
    Offset(0.2, 0.69),
  ];

  final Animation<double> _animation;
  final _RadarPhase phase;
  final SecurityRadarMode mode;
  final _RadarColors colors;
  final Paint _sweepPaint = Paint();
  final Paint _beamPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Paint _pulsePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;
  final Paint _nodePaint = Paint()..style = PaintingStyle.fill;

  Size? _cachedSize;
  Offset _center = Offset.zero;
  double _radius = 0;
  Shader? _sweepShader;
  List<_RadarNode> _nodeGeometry = const [];

  @override
  void paint(Canvas canvas, Size size) {
    _ensureGeometry(size);

    final progress = (phase.value + _animation.value) % 1;
    final angle = progress * math.pi * 2;
    final sweepOpacity = switch (mode) {
      SecurityRadarMode.scanning => 0.46,
      SecurityRadarMode.monitoring => 0.26,
      SecurityRadarMode.blocked => 0.52,
      SecurityRadarMode.unavailable => 0.22,
      SecurityRadarMode.resolved => 0.26,
    };

    _sweepPaint.shader = _sweepShader;
    canvas.save();
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(angle + _beamWidth / 2);
    canvas.translate(-_center.dx, -_center.dy);
    canvas.drawCircle(_center, _radius, _sweepPaint);
    canvas.restore();

    _beamPaint.color = colors.activeStroke.withAlpha(
      (255 * sweepOpacity).round(),
    );
    canvas.drawLine(
      _center,
      _center + Offset(math.cos(angle), math.sin(angle)) * _radius,
      _beamPaint,
    );

    if (mode == SecurityRadarMode.scanning) {
      final pulseProgress = (progress * 2) % 1;
      final pulseOpacity = math.pow(1 - pulseProgress, 2).toDouble();
      _pulsePaint.color = colors.activeStroke.withAlpha(
        (130 * pulseOpacity).round(),
      );
      canvas.drawCircle(
        _center,
        _radius * (0.2 + pulseProgress * 0.8),
        _pulsePaint,
      );
    }

    for (final node in _nodeGeometry) {
      final delta = math
          .atan2(math.sin(node.angle - angle), math.cos(node.angle - angle))
          .abs();
      final proximity = math.max(0.0, 1 - delta / _beamWidth);
      final intensity = switch (mode) {
        SecurityRadarMode.unavailable => 0.22,
        _ => 0.24 + 0.76 * proximity * proximity,
      };
      _nodePaint.color = colors.activeStroke.withAlpha(
        (255 * intensity).round(),
      );
      canvas.drawCircle(node.position, 2.2 + intensity * 1.8, _nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SecurityRadarSweepPainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.colors != colors;

  void _ensureGeometry(Size size) {
    if (_cachedSize == size) {
      return;
    }

    _cachedSize = size;
    _center = Offset(size.width / 2, size.height / 2);
    _radius = math.min(size.height * 0.4, size.width * 0.2);
    final radarBounds = Rect.fromCircle(center: _center, radius: _radius);
    final sweepAlpha = switch (mode) {
      SecurityRadarMode.scanning => 116,
      SecurityRadarMode.monitoring => 68,
      SecurityRadarMode.blocked => 132,
      SecurityRadarMode.unavailable => 52,
      SecurityRadarMode.resolved => 68,
    };
    _sweepShader = SweepGradient(
      colors: [
        colors.activeStroke.withAlpha(0),
        colors.activeStroke.withAlpha(0),
        colors.activeStroke.withAlpha(sweepAlpha),
      ],
      stops: const [0, 0.79, 1],
    ).createShader(radarBounds);
    _nodeGeometry = [
      for (final node in _nodes)
        _RadarNode(
          position: _center + node * _radius,
          angle: math.atan2(node.dy, node.dx),
        ),
    ];
  }
}

final class _RadarPhase {
  _RadarPhase(this.value);

  double value;
}

final class _RadarNode {
  const _RadarNode({required this.position, required this.angle});

  final Offset position;
  final double angle;
}
